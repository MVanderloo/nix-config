{ config, pkgs, ... }:

let
  stateDirectory = "/var/lib/hermes-agent";
  dashboardAddress = "127.0.0.1";
  dashboardPort = 9119;
  webuiPort = 8787;
  containerNetwork = "hermes-agent";
  agentSourceVolume = "hermes-agent-source-v2026-08-31";

  hermesConfig = (pkgs.formats.yaml { }).generate "config.yaml" {
    model = {
      provider = "openai-codex";
      default = "gpt-5.5";
    };

    terminal = {
      backend = "local";
      cwd = "/opt/data/workspace";
    };

    approvals = {
      mode = "smart";
      cron_mode = "deny";
      single_query_mode = "deny";
      unattended_mode = "deny";
    };

    security.redact_secrets = true;

    tool_loop_guardrails = {
      hard_stop_enabled = true;
      hard_stop_after = {
        exact_failure = 5;
        idempotent_no_progress = 5;
      };
    };
  };

  managedConfigDirectory = pkgs.runCommand "hermes-agent-managed-config" { } ''
    mkdir -p "$out"
    cp ${hermesConfig} "$out/config.yaml"
  '';
in
{
  sops = {
    secrets = {
      hermes-dashboard-password.sopsFile = ../../../secrets/theta-hermes.yaml;
      hermes-dashboard-session-secret.sopsFile = ../../../secrets/theta-hermes.yaml;
      hermes-openrouter-api-key.sopsFile = ../../../secrets/theta-hermes.yaml;
    };

    templates."hermes-agent.env" = {
      content = ''
        API_SERVER_KEY=${config.sops.placeholder.hermes-dashboard-session-secret}
        HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=${config.sops.placeholder.hermes-dashboard-password}
        HERMES_DASHBOARD_BASIC_AUTH_SECRET=${config.sops.placeholder.hermes-dashboard-session-secret}
        OPENROUTER_API_KEY=${config.sops.placeholder.hermes-openrouter-api-key}
      '';
      mode = "0400";
      restartUnits = [ "podman-hermes-agent.service" ];
    };

    templates."hermes-webui.env" = {
      content = ''
        HERMES_WEBUI_GATEWAY_API_KEY=${config.sops.placeholder.hermes-dashboard-session-secret}
        HERMES_WEBUI_PASSWORD=${config.sops.placeholder.hermes-dashboard-password}
        OPENROUTER_API_KEY=${config.sops.placeholder.hermes-openrouter-api-key}
      '';
      mode = "0400";
      restartUnits = [ "podman-hermes-webui.service" ];
    };
  };

  users = {
    groups.hermes-agent.gid = 10000;
    users.hermes-agent = {
      isSystemUser = true;
      uid = 10000;
      group = "hermes-agent";
      home = stateDirectory;
    };
  };

  virtualisation.oci-containers = {
    backend = "podman";

    containers.hermes-agent = {
      image = "docker.io/nousresearch/hermes-agent:v2026.8.31@sha256:64923faeae267792bf9bf87fe3b4c4869e35004e360c7df01730ad801b74d524";

      cmd = [
        "gateway"
        "run"
      ];

      environment = {
        API_SERVER_ENABLED = "true";
        API_SERVER_HOST = "0.0.0.0";
        HERMES_DASHBOARD = "1";
        HERMES_DASHBOARD_BASIC_AUTH_USERNAME = "mv";
        HERMES_DASHBOARD_HOST = "0.0.0.0";
        HERMES_DASHBOARD_PORT = toString dashboardPort;
        HERMES_GID = "10000";
        HERMES_MANAGED = "NixOS";
        HERMES_MANAGED_DIR = "/etc/hermes";
        HERMES_UID = "10000";
      };

      environmentFiles = [ config.sops.templates."hermes-agent.env".path ];

      extraOptions = [
        "--network=${containerNetwork}"
        "--security-opt=no-new-privileges"
        "--shm-size=1g"
      ];

      ports = [ "${dashboardAddress}:${toString dashboardPort}:${toString dashboardPort}/tcp" ];
      pull = "missing";

      volumes = [
        "${agentSourceVolume}:/opt/hermes"
        "${stateDirectory}:/opt/data"
        "${managedConfigDirectory}:/etc/hermes:ro"
      ];
    };

    containers.hermes-webui = {
      image = "ghcr.io/nesquena/hermes-webui:0.52.264@sha256:1cbd42331e2046706230310e5fa0db537860536b87e7011630d4d4b6eebab2e2";

      environment = {
        HERMES_API_URL = "http://hermes-agent:8642";
        HERMES_HOME = "/home/hermeswebui/.hermes";
        HERMES_WEBUI_HOST = "0.0.0.0";
        HERMES_WEBUI_PORT = toString webuiPort;
        HERMES_WEBUI_STATE_DIR = "/home/hermeswebui/.hermes/webui";
        WANTED_GID = "10000";
        WANTED_UID = "10000";
      };

      environmentFiles = [ config.sops.templates."hermes-webui.env".path ];

      extraOptions = [
        "--network=${containerNetwork}"
        "--security-opt=no-new-privileges"
      ];

      ports = [ "${dashboardAddress}:${toString webuiPort}:${toString webuiPort}/tcp" ];
      pull = "missing";

      volumes = [
        "${stateDirectory}:/home/hermeswebui/.hermes"
        "${agentSourceVolume}:/home/hermeswebui/.hermes/hermes-agent:ro"
        "${stateDirectory}/workspace:/workspace"
      ];
    };
  };

  systemd = {
    tmpfiles.rules = [
      "d ${stateDirectory} 0700 hermes-agent hermes-agent -"
      "d ${stateDirectory}/workspace 0700 hermes-agent hermes-agent -"
    ];

    services = {
      podman-network-hermes-agent = {
        description = "Podman network for Hermes Agent";
        wantedBy = [ "multi-user.target" ];

        script = ''
          if ! ${pkgs.podman}/bin/podman network exists ${containerNetwork}; then
            ${pkgs.podman}/bin/podman network create ${containerNetwork}
          fi
        '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "-${pkgs.podman}/bin/podman network rm ${containerNetwork}";
        };
      };

      podman-hermes-agent = {
        requires = [ "podman-network-hermes-agent.service" ];
        after = [ "podman-network-hermes-agent.service" ];
      };

      podman-hermes-webui = {
        requires = [
          "podman-hermes-agent.service"
          "podman-network-hermes-agent.service"
        ];
        after = [
          "podman-hermes-agent.service"
          "podman-network-hermes-agent.service"
        ];
      };

      hermes-agent-tailscale-serve = {
        description = "Expose Hermes interfaces through Tailscale Serve";
        wantedBy = [ "multi-user.target" ];
        requires = [
          "podman-hermes-agent.service"
          "podman-hermes-webui.service"
          "tailscaled.service"
        ];
        after = [
          "podman-hermes-agent.service"
          "podman-hermes-webui.service"
          "tailscaled.service"
        ];

        script = ''
          ${pkgs.tailscale}/bin/tailscale serve --yes --bg --https=443 --set-path=/ http://${dashboardAddress}:${toString webuiPort}
          ${pkgs.tailscale}/bin/tailscale serve --yes --bg --https=9443 --set-path=/ http://${dashboardAddress}:${toString dashboardPort}
        '';

        preStop = ''
          ${pkgs.tailscale}/bin/tailscale serve --yes --https=443 --set-path=/ off
          ${pkgs.tailscale}/bin/tailscale serve --yes --https=9443 --set-path=/ off
        '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
    };
  };

  preservation.preserveAt."/persist".directories = [
    {
      directory = stateDirectory;
      user = "hermes-agent";
      group = "hermes-agent";
      mode = "0700";
    }
  ];
}
