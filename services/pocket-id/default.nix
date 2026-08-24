{
  config,
  lib,
  pkgs,
  ...
}:
let
  hostname = "id.mvanderloo.com";
  port = 1411;
  dataDir = "/var/lib/pocket-id";
  networkName = "pocket-id";
  sopsFile = ../../hosts/theta/secrets.yaml;
in
{
  config = {
    sops.secrets."pocket-id/encryption_key" = {
      inherit sopsFile;
      restartUnits = [ "podman-pocket-id.service" ];
    };

    systemd.tmpfiles.rules = [
      "d ${dataDir} 0750 root root -"
      "d ${dataDir}/data 0750 root root -"
    ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.pocket-id = {
        image = "ghcr.io/pocket-id/pocket-id:v2";
        autoStart = true;
        ports = [ "${toString port}:1411" ];
        environment = {
          APP_URL = "https://${hostname}";
          ENCRYPTION_KEY_FILE = "/run/secrets/encryption_key";
          TRUST_PROXY = "true";
          PUID = "1000";
          PGID = "1000";
        };
        volumes = [
          "${dataDir}/data:/app/data"
          "${config.sops.secrets."pocket-id/encryption_key".path}:/run/secrets/encryption_key:ro"
        ];
        extraOptions = [
          "--network=${networkName}"
          "--network-alias=pocket-id"
          "--health-cmd=/app/pocket-id healthcheck"
          "--health-interval=90s"
          "--health-timeout=5s"
          "--health-retries=2"
          "--health-start-period=10s"
        ];
      };
    };

    systemd.services.podman-network-pocket-id = {
      description = "Pocket ID podman network";
      wantedBy = [ "multi-user.target" ];
      before = [ "podman-pocket-id.service" ];
      path = [ pkgs.podman ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        podman network exists ${networkName} || podman network create ${networkName}
      '';
    };

    networking.firewall.allowedTCPPorts = [ port ];
  };
}