{
  config,
  pkgs,
  secrets,
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
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  console = {
    packages = [ pkgs.terminus_font ];
    font = "ter-v24n";
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

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets."admin-password-hash" = {
      sopsFile = secrets.adminPassword;
      neededForUsers = true;
    };
  };

  services = {
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

  system.stateVersion = "26.05";
}
