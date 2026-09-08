{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/home-manager/bash.nix
    ../../modules/home-manager/codex.nix
    ../../modules/home-manager/fish.nix
    ../../modules/home-manager/neovim.nix
    ../../modules/home-manager/ssh.nix
    ../../modules/home-manager/syncthing.nix
    ../../modules/home-manager/tmux.nix
    ../../modules/home-manager/tsshd.nix
    ../../modules/home-manager/version-control.nix
    ../../modules/home-manager/xdg.nix
  ];

  home = {
    username = "mv";
    homeDirectory = "/home/mv";
    stateVersion = "26.05";

    sessionVariables.LOCAL_KEY = "${config.xdg.configHome}/nix/alpha-deploy.sec";

    packages = with pkgs; [
      devenv
      opencode
    ];
  };

  programs = {
    atuin.settings.sync_address = "http://127.0.0.1:8888";
    docker-cli.enable = true;
    git.settings.user = {
      name = "Michael van der Loo";
      email = "me@mvanderloo.com";
    };
    jujutsu.settings.user = {
      name = "Michael van der Loo";
      email = "me@mvanderloo.com";
    };
    nh.flake = "${config.home.homeDirectory}/nix-config";
  };

  services.syncthing.deviceName = "theta";
}
