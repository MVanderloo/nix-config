{
  config,
  lib,
  pkgs,
  ...
}:
let
  hostname = "atuin.mvanderloo.com";
  port = 8888;
  dataDir = "/var/lib/atuin";
  networkName = "atuin";
  sopsFile = ../../hosts/theta/secrets.yaml;
in
{
  config = {
    sops.secrets."atuin/db_password" = {
      inherit sopsFile;
      restartUnits = [ "atuin-config.service" ];
    };

    systemd.tmpfiles.rules = [
      "d ${dataDir} 0750 root root -"
      "d ${dataDir}/postgres 0750 root root -"
      "d ${dataDir}/config 0750 root root -"
    ];

    systemd.services.atuin-config = {
      description = "Generate Atuin server config";
      wantedBy = [ "multi-user.target" ];
      before = [ "podman-atuin.service" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      script = ''
        cat > ${dataDir}/config/server.toml << TOML
        host = "0.0.0.0"
        port = ${toString port}
        open_registration = false
        db_uri = "postgresql://atuin:$(cat ${config.sops.secrets."atuin/db_password".path})@atuin-db:5432/atuin"
        TOML
        chmod 600 ${dataDir}/config/server.toml
      '';
    };

    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        atuin-db = {
          image = "docker.io/library/postgres:18-alpine";
          autoStart = true;
          environment = {
            POSTGRES_USER = "atuin";
            POSTGRES_PASSWORD_FILE = "/run/secrets/db_password";
            POSTGRES_DB = "atuin";
          };
          volumes = [
            "${dataDir}/postgres:/var/lib/postgresql/data"
            "${config.sops.secrets."atuin/db_password".path}:/run/secrets/db_password:ro"
          ];
          extraOptions = [
            "--network=${networkName}"
            "--network-alias=atuin-db"
            "--health-cmd=pg_isready -U atuin -d atuin"
            "--health-interval=10s"
            "--health-timeout=5s"
            "--health-retries=5"
            "--health-start-period=10s"
          ];
        };

        atuin = {
          image = "ghcr.io/atuinsh/atuin:main";
          autoStart = true;
          ports = [ "${toString port}:${toString port}" ];
          environment = {
            ATUIN_CONFIG_DIR = "/config";
          };
          volumes = [ "${dataDir}/config:/config:ro" ];
          dependsOn = [ "atuin-db" ];
          extraOptions = [
            "--network=${networkName}"
            "--network-alias=atuin"
            "--health-cmd=curl -f http://localhost:${toString port} || exit 1"
            "--health-interval=30s"
            "--health-timeout=10s"
            "--health-retries=3"
            "--health-start-period=30s"
          ];
        };
      };
    };

    systemd.services.podman-network-atuin = {
      description = "Atuin podman network";
      wantedBy = [ "multi-user.target" ];
      before = [
        "podman-atuin-db.service"
        "podman-atuin.service"
      ];
      path = [ pkgs.podman ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        podman network exists ${networkName} || podman network create ${networkName}
      '';
    };

    systemd.services.podman-atuin = {
      after = [ "atuin-config.service" ];
      requires = [ "atuin-config.service" ];
    };

    networking.firewall.allowedTCPPorts = [ port ];
  };
}