{
  config,
  secrets,
  sshPublicKeys,
  ...
}:

{
  networking.hostName = "alpha";

  environment.enableAllTerminfo = true;
  i18n.defaultLocale = "en_US.UTF-8";
  networking.firewall.enable = true;
  time.timeZone = "America/New_York";

  zramSwap = {
    enable = true;
    memoryPercent = 100;
    priority = 100;
  };

  swapDevices = [
    {
      device = "/persist/swapfile";
      size = 1024;
      priority = 10;
    }
  ];

  users = {
    mutableUsers = false;

    users.mv = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = config.sops.secrets."admin-password-hash".path;
      openssh.authorizedKeys.keys = [ sshPublicKeys.yubikey ];
    };
  };

  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  nix.settings.trusted-public-keys = [
    "alpha-deploy-1:2ktAcE8zWZMsjmGTxnZF0LlWIlRPrwCW/iO6IqOkI9E="
  ];

  programs.ssh.knownHosts.github = {
    hostNames = [ "github.com" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };

  services = {
    openssh = {
      openFirewall = false;
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

    tailscale.extraSetFlags = [ "--ssh" ];
  };

  sops = {
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];

    secrets."admin-password-hash" = {
      sopsFile = secrets.adminPassword;
      neededForUsers = true;
    };
  };

  virtualisation.oci-containers.backend = "podman";

  system.stateVersion = "26.05";
}
