{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:

{
  networking.hostName = "tau";

  users = {
    mutableUsers = false;
    users.mv = {
      isNormalUser = true;
      extraGroups = [
        "lp"
        "networkmanager"
        "wheel"
      ];
      hashedPasswordFile = config.sops.secrets."admin-password-hash".path;
      linger = true;
      shell = pkgs.fish;
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 2;
    };

    plymouth.penguin = {
      imageSize = 480;
      dialogWidth = 720;
      dialogHeight = 150;
      promptFontSize = 26;
    };

    # This was added to solve some issue but I cannot remember
    # kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    firewall.enable = true;

    networkmanager = {
      enable = true;
      # not sure if I added these for a reason.
      # let's see if it breaks!
      # dns = "systemd-resolved";
      # wifi.backend = "iwd";
    };
  };

  console = {
    font = "ter-v32n";
    packages = [ pkgs.terminus_font ];
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    enableRedistributableFirmware = true;

    gpgSmartcards.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  powerManagement.enable = true;

  environment = {
    enableAllTerminfo = true;

    variables.CODEX_HOME = "/home/mv/.config/codex";

    systemPackages = with pkgs; [
      brightnessctl
      playerctl
      smartmontools
      system-config-printer
      usbutils
      xwayland-satellite
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    nerd-fonts.ubuntu-mono
  ];

  nixpkgs.config.allowUnfreePackages = [
    "1password"
    "1password-cli"
  ];

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "mv" ];
    };
    dconf.enable = true;
    fish.enable = true;
    helium = {
      enable = true;
      # Helium already bundles uBlock Origin.
      policies.ExtensionInstallForcelist = [
        "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1Password
        "hfjbmagddngcpeloejdejnfgbamkjaeg" # Vimium C
        "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
      ];
    };
    niri.enable = true;
    yubikey-manager.enable = true;
  };

  services = {
    # Let NetworkManager and Tailscale register DNS per link, avoiding stale
    # upstream resolvers in Tailscale's openresolv integration.
    resolved.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    fwupd.enable = true;
    gvfs.enable = true;
    hardware.bolt.enable = true;
    ipp-usb.enable = true;
    libinput.enable = true;
    openssh = {
      enable = true;
      # Tau may use its built-in NIC, a USB dock, Wi-Fi, or Tailscale. SSH is
      # key-only and restricted to mv below, so do not couple first access to
      # a topology-derived interface name.
      openFirewall = true;
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
      settings = {
        AllowUsers = [ "mv" ];
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    printing.enable = true;
    tailscale.extraSetFlags = [ "--ssh" ];
    thermald.enable = true;
    udisks2.enable = true;
    xserver.xkb.options = lib.mkForce "ctrl:nocaps,altwin:swap_lalt_lwin";
  };

  security = {
    sudo = {
      # TODO: Require authentication again after unattended reinstall is stable.
      wheelNeedsPassword = false;
      extraConfig = ''
        Defaults lecture = never
      '';
    };
  };

  sops = {
    # The installer must seed this key under /persist before activation.
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    secrets."admin-password-hash" = {
      sopsFile = secrets.adminPassword;
      neededForUsers = true;
    };
  };

  system.stateVersion = "26.05";
}
