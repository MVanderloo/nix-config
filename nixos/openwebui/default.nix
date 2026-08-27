{ lib, pkgs, ... }:
let
  hostname = ""; # empty = local / Tailscale only
  port = 8080;
  dataDir = "/var/lib/openwebui";
  networkName = "openwebui";
  ollamaExternalUrl = "http://delta:8041"; # set to "" for bundled ollama
in
{
  config = {
    virtualisation.oci-containers = {
      backend = "podman";
      containers.openwebui = {
        image = "ghcr.io/open-webui/open-webui:main";
        autoStart = true;
        ports = [ "${toString port}:8080" ];
        volumes = [ "${dataDir}/open-webui:/app/backend/data" ];
        environment = {
          OLLAMA_BASE_URL =
            if ollamaExternalUrl != "" then ollamaExternalUrl else "http://host.containers.internal:11434";
        }
        // lib.optionalAttrs (hostname != "") {
          WEBUI_URL = "https://${hostname}";
        };
        extraOptions = [
          "--network=${networkName}"
          "--network-alias=openwebui"
          "--health-cmd=curl -f http://localhost:8080 || exit 1"
          "--health-interval=30s"
          "--health-timeout=10s"
          "--health-retries=3"
          "--health-start-period=30s"
        ];
      };
    };

    systemd = {
      tmpfiles.rules = [
        "d ${dataDir} 0750 root root -"
        "d ${dataDir}/ollama 0750 root root -"
        "d ${dataDir}/open-webui 0750 root root -"
      ];

      services.podman-network-openwebui = {
        description = "OpenWebUI podman network";
        wantedBy = [ "multi-user.target" ];
        before = [ "podman-openwebui.service" ];
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          podman network exists ${networkName} || podman network create ${networkName}
        '';
      };
    };

    networking.firewall.allowedTCPPorts = [ port ];
  };
}
