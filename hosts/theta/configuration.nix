{ pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.mv = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    hostName = "theta";
    networkmanager.enable = true;

    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # firewall.enable = false;
    firewall.interfaces.tailscale0.allowedUDPPortRanges = [
      {
        from = 60000;
        to = 61000;
      }
    ];

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    tailscale.enable = true;
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
    };
    fwupd.enable = true;
  };

  systemd = {
    tmpfiles.rules = [
      "d /var/lib/atuin 0755 root root -"
    ];

    services.atuin-server = {
      description = "Atuin sync server";
      wantedBy = [ "default.target" ];
      path = [ pkgs.atuin ];
      environment = {
        ATUIN_HOST = "0.0.0.0";
        ATUIN_PORT = "8888";
        ATUIN_OPEN_REGISTRATION = "true";
        ATUIN_DB_URI = "sqlite:///var/lib/atuin/atuin.db";
      };
      script = "atuin-server start";
    };
  };

  system.stateVersion = "26.05";
}
