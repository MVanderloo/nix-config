{
  config,
  lib,
  pkgs,
  ...
}:
{
  nix = {
    settings = {
      trusted-users = [ "mv" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 10d";
    };
  };

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
    atuin = {
      enable = true;
      host = "127.0.0.1";
      openRegistration = false;
      database = {
        createLocally = false;
        uri = "sqlite:///var/lib/atuin/atuin.db";
      };
    };

    tailscale = {
      enable = true;
      extraSetFlags = [ "--ssh" ];
    };
    fwupd.enable = true;
  };

  systemd = {
    services = {
      atuin.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = config.users.users.mv.name;
        Group = config.users.users.mv.group;
        StateDirectory = "atuin";
        StateDirectoryMode = "0700";
        Restart = "on-failure";
        RestartSec = "5s";
      };

      atuin-tailscale-serve = {
        description = "Expose Atuin through Tailscale Serve";
        wantedBy = [ "multi-user.target" ];
        requires = [
          "atuin.service"
          "tailscaled.service"
        ];
        after = [
          "atuin.service"
          "tailscaled.service"
        ];

        script = ''
          ${pkgs.tailscale}/bin/tailscale serve \
            --yes \
            --bg \
            --http=${toString config.services.atuin.port} \
            --set-path=/ \
            http://${config.services.atuin.host}:${toString config.services.atuin.port}
        '';

        preStop = ''
          ${pkgs.tailscale}/bin/tailscale serve \
            --yes \
            --http=${toString config.services.atuin.port} \
            --set-path=/ \
            off
        '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    };

    tmpfiles.rules = [
      "Z /var/lib/atuin - ${config.users.users.mv.name} ${config.users.users.mv.group} - -"
    ];
  };

  system.stateVersion = "26.05";
}
