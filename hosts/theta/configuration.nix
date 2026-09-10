{
  config,
  lib,
  pkgs,
  secrets,
  sshPublicKeys,
  ...
}:

{
  networking.hostName = "theta";

  users = {
    mutableUsers = false;

    users.mv = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = config.sops.secrets."admin-password-hash".path;
      linger = true;
      openssh.authorizedKeys.keys = [ sshPublicKeys.yubikey ];
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;

    # Mask malfunctioning AHCI port 4 (ata5), which adds
    # about 45 seconds of IDENTIFY timeouts to boot.
    kernelParams = [ "ahci.mask_port_map=0x2f" ];
  };

  hardware.graphics.enable = true;

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  environment = {
    enableAllTerminfo = true;
    variables.CODEX_HOME = "/home/mv/.config/codex";
    systemPackages = [
      pkgs.wakeonlan
      (pkgs.writeShellApplication {
        name = "wake-delta";
        runtimeInputs = [ pkgs.wakeonlan ];
        text = "exec wakeonlan -i 192.168.0.255 -p 9 10:ff:e0:c4:56:ed";
      })
    ];
  };

  programs.ssh.knownHosts.github = {
    hostNames = [ "github.com" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets."admin-password-hash" = {
      sopsFile = secrets.adminPassword;
      neededForUsers = true;
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

    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        AllowUsers = [ "mv" ];
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    tailscale.extraSetFlags = [ "--ssh" ];
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
