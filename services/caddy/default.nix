{
  config,
  lib,
  pkgs,
  ...
}:
let
  httpPort = 80;
  httpsPort = 443;
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
  config = {
    systemd.tmpfiles.rules = [
      "d ${dataDir} 0750 root root -"
      "d ${dataDir}/data 0750 root root -"
      "d ${dataDir}/config 0750 root root -"
    ];

    networking.firewall.allowedTCPPorts = [
      httpPort
      httpsPort
    ];

    systemd.services.caddy-config = {
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

    virtualisation.oci-containers = {
      backend = "podman";
      containers.caddy = {
        image = "docker.io/library/caddy:2-alpine";
        autoStart = true;
        ports = [
          "${toString httpPort}:80"
          "${toString httpsPort}:443"
        ];
        volumes = [
          "${dataDir}/data:/data"
          "${dataDir}/config/Caddyfile:/etc/caddy/Caddyfile:ro"
        ];
        extraOptions = [ "--network=${networkName}" ];
      };
    };

    systemd.services.podman-caddy = {
      after = [ "caddy-config.service" ];
      requires = [ "caddy-config.service" ];
    };

    systemd.services.podman-network-caddy = {
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
}