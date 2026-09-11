{ config, pkgs, ... }:

let
  image = "ghcr.io/gethomepage/homepage:v2.3.0@sha256:f820276654539cdc2cf0169f28188d135919a7984fad76d83d8d5ff1383f3705";
  port = 3000;
  tailscalePort = 8444;
  tailnetDomain = "bongo-sidemirror.ts.net";
  hostname = "${config.networking.hostName}.${tailnetDomain}";
  backendUrl = "http://127.0.0.1:${toString port}";
  yaml = pkgs.formats.yaml { };

  services = [
    {
      Theta = [
        {
          "Hermes Web UI" = {
            href = "https://${hostname}";
            description = "Chat with Hermes Agent";
          };
        }
        {
          "Hermes Dashboard" = {
            href = "https://${hostname}:9443";
            description = "Hermes Agent dashboard";
          };
        }
        {
          "Home Assistant" = {
            href = "http://${hostname}:8123";
            description = "Home automation";
          };
        }
        {
          Atuin = {
            href = "http://${hostname}:${toString config.services.atuin.port}";
            description = "Shell history sync API";
          };
        }
      ];
    }
    {
      Omega = [
        {
          Homepage = {
            href = "https://omega.${tailnetDomain}";
            description = "Existing Omega dashboard";
          };
        }
        {
          Arcane = {
            href = "http://omega.${tailnetDomain}:3552";
            description = "Container management";
          };
        }
        {
          FreshRSS = {
            href = "http://omega.${tailnetDomain}:8082";
            description = "RSS reader";
          };
        }
        {
          Syncthing = {
            href = "http://omega.${tailnetDomain}:8384";
            description = "File synchronization";
          };
        }
        {
          "Shape of the Day" = {
            href = "http://omega.${tailnetDomain}:3000";
            description = "Daily shape";
          };
        }
      ];
    }
    {
      Delta = [
        {
          "Rayfish Metrics" = {
            href = "http://delta.${tailnetDomain}:9090";
            description = "Rayfish Prometheus metrics";
          };
        }
      ];
    }
    {
      "Unavailable — reminders" = [
        {
          "Personal Website" = {
            href = "https://mvanderloo.com";
            description = "Check Caddy upstream: returns HTTP 404";
          };
        }
        {
          "Pocket ID" = {
            href = "https://id.mvanderloo.com";
            description = "Fix reverse proxy: returns HTTP 502";
          };
        }
        {
          "Hermes Dashboard (Delta)" = {
            href = "https://delta.${tailnetDomain}";
            description = "Restore backend: Tailscale Serve returns HTTP 502";
          };
        }
        {
          "Syncthing (Delta)" = {
            href = "http://delta.${tailnetDomain}:8384";
            description = "Expose GUI to tailnet: currently listens on localhost only";
          };
        }
        {
          "Syncthing (Tau)" = {
            href = "http://tau.${tailnetDomain}:8384";
            description = "Verify GUI access when Tau is online; old dashboard IP was stale";
          };
        }
      ];
    }
  ];

  configFiles = {
    "settings.yaml" = yaml.generate "settings.yaml" { };
    "services.yaml" = yaml.generate "services.yaml" services;
    "bookmarks.yaml" = yaml.generate "bookmarks.yaml" [ ];
    "widgets.yaml" = yaml.generate "widgets.yaml" [ ];
    "docker.yaml" = yaml.generate "docker.yaml" { };
    "kubernetes.yaml" = yaml.generate "kubernetes.yaml" { };
    "proxmox.yaml" = yaml.generate "proxmox.yaml" { };
    "custom.css" = pkgs.writeText "custom.css" "";
    "custom.js" = pkgs.writeText "custom.js" "";
  };

  # Copy files rather than linking: store symlink targets aren't in the container.
  configDirectory = pkgs.runCommand "homepage-config" { } (
    "mkdir -p $out\n"
    + pkgs.lib.concatStringsSep "\n" (
      pkgs.lib.mapAttrsToList (name: file: "cp ${file} $out/${name}") configFiles
    )
  );
in
{
  virtualisation.quadlet.containers.homepage = {
    autoStart = true;

    unitConfig.Description = "Homepage dashboard";

    containerConfig = {
      image = image;
      user = "1000:1000";
      readOnly = true;
      noNewPrivileges = true;
      dropCapabilities = [ "ALL" ];

      environments = {
        HOMEPAGE_ALLOWED_HOSTS = "${hostname}:${toString tailscalePort}";
        HOSTNAME = "0.0.0.0";
        LOG_TARGETS = "stdout";
        TZ = config.time.timeZone;
      };

      publishPorts = [ "127.0.0.1:${toString port}:3000" ];
      volumes = [ "${configDirectory}:/app/config:ro" ];
      tmpfses = [
        "/app/.next/cache:U,mode=0700"
        "/tmp:U,mode=0700"
      ];
    };

    serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
      TimeoutStartSec = "900s";
    };
  };

  systemd.services.homepage-tailscale-serve = {
    description = "Expose Homepage through Tailscale Serve";
    wantedBy = [ "multi-user.target" ];
    requires = [
      "tailscaled.service"
      "homepage.service"
    ];
    after = [
      "tailscaled.service"
      "homepage.service"
    ];

    script = ''
      ${pkgs.tailscale}/bin/tailscale serve \
        --yes \
        --bg \
        --https=${toString tailscalePort} \
        --set-path=/ \
        ${backendUrl}
    '';

    preStop = ''
      ${pkgs.tailscale}/bin/tailscale serve \
        --yes \
        --https=${toString tailscalePort} \
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
}
