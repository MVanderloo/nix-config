{ config, ... }:

{
  virtualisation.quadlet = {
    enable = true;

    containers.caddy = {
      containerConfig = {
        image = "ghcr.io/11notes/caddy:2.11.4@sha256:1d7827cc08df2ea2076b6bdc52401d3324797bdf190c0787e1c75260d56f60f3";

        # Caddy puts certificates and instance metadata in $XDG_DATA_HOME/caddy.
        environments.XDG_DATA_HOME = "/caddy/var";

        exec = [
          "run"
          "--config"
          "/caddy/etc/Caddyfile"
        ];

        volumes = [
          "${./Caddyfile}:/caddy/etc/Caddyfile:ro"
          "/var/lib/caddy:/caddy/var"
          "/var/lib/caddy-config:/caddy/backup"
        ];

        networks = [ config.virtualisation.quadlet.networks.auth.ref ];

        publishPorts = [
          "80:80"
          "443:443"
          "443:443/udp"
        ];

        sysctl."net.ipv4.ip_unprivileged_port_start" = "80";
      };

      serviceConfig.Restart = "always";
    };
  };

  preservation.preserveAt."/nix/persist".directories = [
    {
      directory = "/var/lib/caddy";
      user = "1000";
      group = "1000";
      mode = "0750";
    }
    {
      directory = "/var/lib/caddy-config";
      user = "1000";
      group = "1000";
      mode = "0750";
    }
  ];

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [ 443 ];
  };
}
