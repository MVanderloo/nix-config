{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/codex.nix
    ../../modules/home-manager/fish.nix
    ../../modules/home-manager/ghostty.nix
    ../../modules/home-manager/neovim.nix
    ../../modules/home-manager/niri.nix
    ../../modules/home-manager/noctalia.nix
    ../../modules/home-manager/pi.nix
    ../../modules/home-manager/python.nix
    ../../modules/home-manager/ssh-gpg.nix
    ../../modules/home-manager/syncthing.nix
    ../../modules/home-manager/tailscale-ssh.nix
    ../../modules/home-manager/tmux.nix
    ../../modules/home-manager/tsshd.nix
    ../../modules/home-manager/version-control.nix
    ../../modules/home-manager/xdg.nix
  ];

  home = {
    stateVersion = "26.05";
    username = "mv";
    homeDirectory = "/home/mv";

    packages = with pkgs; [
      devenv
      rayfish
      vesktop
    ];

    sessionVariables.LOCAL_KEY = "${config.xdg.configHome}/nix/alpha-deploy.sec";
  };

  programs = {
    atuin.settings.sync_address = "http://theta:8888";
    docker-cli.enable = true;
    git.settings.user = {
      name = "Michael van der Loo";
      email = "me@mvanderloo.com";
    };
    home-manager.enable = true;
    jujutsu.settings.user = {
      name = "Michael van der Loo";
      email = "me@mvanderloo.com";
    };
    nh.flake = "${config.home.homeDirectory}/Repositories/nix-config";

    noctalia.settings.lockscreen_widgets = {
      widget_order = [
        "lockscreen-login-box@eDP-1"
        "clock"
        "weather"
      ];
      widget = {
        clock.cx = 1280.0;
        weather.cx = 1280.0;
        "lockscreen-login-box@eDP-1" = {
          box_height = 70.0;
          box_width = 400.0;
          cx = 1280.0;
          cy = 720.0;
          output = "eDP-1";
          type = "login_box";
        };
      };
    };
    noctalia.settings.wallpaper.default.path = "${../../assets/wallpapers}/catpuccin_landscape.png";
  };

  services.syncthing.deviceName = "tau";

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = [ "helium.desktop" ];
      "x-scheme-handler/https" = [ "helium.desktop" ];
      "text/html" = [ "helium.desktop" ];
      "application/xhtml+xml" = [ "helium.desktop" ];
    };
  };

  wayland.windowManager.niri.settings.input = {
    keyboard.xkb.options = "caps:ctrl_modifier,altwin:swap_lalt_lwin";
    touchpad.accel-speed = 0.4;
  };
}
