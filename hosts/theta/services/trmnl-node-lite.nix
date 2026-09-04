{
  config,
  lib,
  pkgs,
  ...
}:

let
  port = 2300;
  backendPort = 2301;
  tailscalePreviewPort = 8443;
  refreshRateSeconds = 900;
  lanInterfaces = [
    "eno1"
    "wlp1s0"
  ];

  # Node Lite logs the device ID on a rejected setup request. Set this to that
  # Wi-Fi MAC after the first provisioning attempt.
  deviceMac = null;

  package = pkgs.callPackage ../../../packages/byos-node-lite { };
  appDirectory = "${package}/lib/node_modules/byos_node_lite";
  lanUrl = "http://${config.networking.hostName}.local:${toString port}";
  backendUrl = "http://127.0.0.1:${toString backendPort}";

  getOnlyProxy = {
    proxyPass = backendUrl;
    extraConfig = ''
      limit_except GET { deny all; }
    '';
  };
in
{
  assertions = [
    {
      assertion =
        deviceMac == null
        || builtins.match "[[:xdigit:]]{2}(:[[:xdigit:]]{2}){5}" deviceMac != null;
      message = "TRMNL Node Lite deviceMac must be a colon-separated MAC address";
    }
  ];

  sops = {
    secrets = {
      node-lite-secret-key = {
        sopsFile = ../../../secrets/theta-trmnl.yaml;
        restartUnits = [ "trmnl-node-lite.service" ];
      };
      node-lite-device-access-token = {
        sopsFile = ../../../secrets/theta-trmnl.yaml;
        restartUnits = [ "trmnl-node-lite.service" ];
      };
    };

    templates."trmnl-node-lite.env" = {
      content = ''
        SECRET_KEY=${config.sops.placeholder.node-lite-secret-key}
        BYOS_DEVICE_ACCESS_TOKEN=${config.sops.placeholder.node-lite-device-access-token}
      '';
      mode = "0400";
      restartUnits = [ "trmnl-node-lite.service" ];
    };
  };

  services.avahi = {
    enable = true;
    allowInterfaces = lanInterfaces;
    nssmdns4 = true;
    openFirewall = false;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  # The display can reach only the BYOS firmware API and its generated image.
  # The complete preview server remains available through Tailscale Serve.
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    serverTokens = false;

    virtualHosts.trmnl-node-lite-device = {
      default = true;
      listen = [
        {
          addr = "0.0.0.0";
          inherit port;
        }
      ];

      locations = {
        "= /api/display" = getOnlyProxy;
        "= /api/setup" = getOnlyProxy;
        "= /api/log" = {
          proxyPass = backendUrl;
          extraConfig = ''
            limit_except POST { deny all; }
          '';
        };
        "= /image" = getOnlyProxy;
        "/".return = 404;
      };
    };
  };

  networking.firewall.interfaces = lib.genAttrs lanInterfaces (_: {
    allowedTCPPorts = [ port ];
    allowedUDPPorts = [ 5353 ];
  });

  systemd.services = {
    trmnl-node-lite = {
      description = "TRMNL Node Lite BYOS server";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = {
        ALLOW_FIRMWARE_UPDATE = "false";
        BUTTON_2_CLICK_FUNCTION = "sleep";
        BYOS_ENABLED = "true";
        BYOS_PROXY = "false";
        HOME = "/run/trmnl-node-lite";
        PUBLIC_URL_ORIGIN = lanUrl;
        PUPPETEER_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
        PUPPETEER_SKIP_DOWNLOAD = "true";
        REFRESH_RATE_SECONDS = toString refreshRateSeconds;
        SERVER_HOST = "127.0.0.1";
        SERVER_PORT = toString backendPort;
        TZ = config.time.timeZone;
      }
      // lib.optionalAttrs (deviceMac != null) {
        BYOS_DEVICE_MAC = deviceMac;
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.nodejs_22}/bin/node --import tsx src/Main.ts";
        ExecStartPost = pkgs.writeShellScript "trmnl-node-lite-wait-ready" ''
          for attempt in $(${pkgs.coreutils}/bin/seq 1 30); do
            if ${pkgs.curl}/bin/curl \
              --fail \
              --silent \
              --max-time 2 \
              http://127.0.0.1:${toString backendPort}/ \
              >/dev/null; then
              exit 0
            fi
            ${pkgs.coreutils}/bin/sleep 1
          done

          echo "TRMNL Node Lite did not become ready in time" >&2
          exit 1
        '';
        WorkingDirectory = appDirectory;
        EnvironmentFile = config.sops.templates."trmnl-node-lite.env".path;
        Restart = "on-failure";
        RestartSec = "5s";
        TimeoutStartSec = "45s";

        DynamicUser = true;
        RuntimeDirectory = "trmnl-node-lite";
        RuntimeDirectoryMode = "0700";
        UMask = "0077";

        CapabilityBoundingSet = "";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
      };
    };

    nginx = {
      requires = [ "trmnl-node-lite.service" ];
      after = [ "trmnl-node-lite.service" ];
    };

    trmnl-node-lite-tailscale-serve = {
      description = "Expose the TRMNL Node Lite preview through Tailscale Serve";
      wantedBy = [ "multi-user.target" ];
      requires = [
        "tailscaled.service"
        "trmnl-node-lite.service"
      ];
      after = [
        "tailscaled.service"
        "trmnl-node-lite.service"
      ];

      script = ''
        ${pkgs.tailscale}/bin/tailscale serve \
          --yes \
          --bg \
          --https=${toString tailscalePreviewPort} \
          --set-path=/ \
          ${backendUrl}
      '';

      preStop = ''
        ${pkgs.tailscale}/bin/tailscale serve \
          --yes \
          --https=${toString tailscalePreviewPort} \
          --set-path=/ \
          off
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
