{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "theta";
  networking.networkmanager.enable = true;
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8888 ];
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true;
  # };

  services.tailscale.enable = true;

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "caps:escape";

  programs.fish.enable = true;

  users.users.mv = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    autoSubUidGidRange = true;
    packages = with pkgs; [
      neovim
      git
    ];
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    atuin
    neovim
    wget
  ];

  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  services.fwupd.enable = true;

  systemd.tmpfiles.rules = [
    "d /var/lib/atuin 0755 root root -"
  ];

  systemd.services.atuin-server = {
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

  system.stateVersion = "26.05";
}
