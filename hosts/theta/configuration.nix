{ config, pkgs, ... }:
{
  nix.settings.trusted-users = [ "mv" ];

  users.users.mv = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    linger = true;
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
    firewall.interfaces.tailscale0 = {
      allowedTCPPorts = [ 22000 ];
      allowedUDPPortRanges = [
        {
          from = 60000;
          to = 61000;
        }
      ];
    };

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  environment = {
    enableAllTerminfo = true;
    systemPackages = [
      pkgs.wakeonlan
      (pkgs.writeShellApplication {
        name = "wake-delta";
        runtimeInputs = [ pkgs.wakeonlan ];
        text = ''
          exec wakeonlan -i 192.168.0.255 -p 9 10:ff:e0:c4:56:ed
        '';
      })
    ];
  };

  programs = {
    mosh = {
      enable = true;
      openFirewall = false;
    };

    ssh.knownHosts.github = {
      hostNames = [ "github.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
  };

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets.github-ssh-key = {
      sopsFile = ../../secrets/theta-github-ssh-key;
      format = "binary";
      owner = config.users.users.mv.name;
      group = config.users.users.mv.group;
      mode = "0400";
    };
  };

  services = {
    tailscale = {
      enable = true;
      extraSetFlags = [ "--ssh" ];
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
