{ pkgs, ... }:
let
  tlsEmail = "admin@mvanderloo.com";
  dataDir = "/var/lib/caddy";
  networkName = "caddy";
  caddyConfig = ''
    id.mvanderloo.com {
      reverse_proxy localhost:1411
    }

    atuin.mvanderloo.com {
      reverse_proxy localhost:8888
    }
  '';
in
{
  config.systemd = {
    tmpfiles.rules = [
      "d ${dataDir} 0750 root root -"
      "d ${dataDir}/data 0750 root root -"
      "d ${dataDir}/config 0750 root root -"
    ];

    services = {
      caddy-config = {
        description = "Generate Caddyfile";
        wantedBy = [ "multi-user.target" ];
        before = [ "podman-caddy.service" ];
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
        script = ''
          cat > ${dataDir}/config/Caddyfile << 'CADDY'
          {
            email ${tlsEmail}
          }

          ${caddyConfig}
          CADDY
        '';
      };

      podman-caddy = {
        after = [ "caddy-config.service" ];
        requires = [ "caddy-config.service" ];
      };

      podman-network-caddy = {
        description = "Caddy podman network";
        wantedBy = [ "multi-user.target" ];
        before = [ "podman-caddy.service" ];
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
  };
}
