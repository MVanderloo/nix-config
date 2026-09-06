{ config, ... }:

{
  assertions = [
    {
      assertion = config.services.tailscale.enable;
      message = "The transitional Caddy configuration requires Tailscale to reach FreshRSS on omega";
    }
  ];

  services.caddy = {
    enable = true;
    configFile = ./Caddyfile;
    openFirewall = true;
  };

  systemd.services.caddy = {
    requires = [ "tailscaled.service" ];
    after = [ "tailscaled.service" ];
  };

  preservation.preserveAt."/persist".directories = [
    {
      directory = "/var/lib/caddy";
      user = "caddy";
      group = "caddy";
      mode = "0700";
    }
  ];
}
