{
  services.tailscale.enable = true;

  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPortRanges = [
      # Mosh
      {
        from = 60000;
        to = 61000;
      }
      # Rootshell Roam / tsshd
      {
        from = 61001;
        to = 61999;
      }
    ];
  };
}
