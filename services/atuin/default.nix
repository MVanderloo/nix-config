{ config, pkgs, ... }:
let
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

    systemd = {
      tmpfiles.rules = [
        "d ${dataDir} 0750 root root -"
        "d ${dataDir}/postgres 0750 root root -"
        "d ${dataDir}/config 0750 root root -"
      ];

      services = {
        atuin-config = {
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
            db_uri = "postgresql://atuin:$(cat ${
              config.sops.secrets."atuin/db_password".path
            })@atuin-db:5432/atuin"
            TOML
            chmod 600 ${dataDir}/config/server.toml
          '';
        };

        podman-network-atuin = {
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

        podman-atuin = {
          after = [ "atuin-config.service" ];
          requires = [ "atuin-config.service" ];
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ port ];
  };
}
