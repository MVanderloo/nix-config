{
  virtualisation.quadlet = {
    enable = true;

    containers.caddy = {
      containerConfig = {
        image = "ghcr.io/11notes/caddy:2.11.4@sha256:1d7827cc08df2ea2076b6bdc52401d3324797bdf190c0787e1c75260d56f60f3";

        exec = [
          "run"
          "--config"
          "/caddy/etc/Caddyfile"
        ];

        volumes = [
          "${./Caddyfile}:/caddy/etc/Caddyfile:ro"
          "/var/lib/caddy:/caddy/var"
        ];

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

  preservation.preserveAt."/persist".directories = [
    {
      directory = "/var/lib/caddy";
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
