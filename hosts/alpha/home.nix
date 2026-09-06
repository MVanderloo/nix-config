{ pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/bash.nix
    ../../modules/home-manager/codex.nix
    ../../modules/home-manager/fish.nix
    ../../modules/home-manager/neovim.nix
    ../../modules/home-manager/ssh.nix
    ../../modules/home-manager/syncthing.nix
    ../../modules/home-manager/tmux.nix
    ../../modules/home-manager/version-control.nix
    ../../modules/home-manager/xdg.nix
  ];

  home = {
    username = "mv";
    homeDirectory = "/home/mv";
    stateVersion = "26.05";

    # packages = with pkgs; [ ];
  };

  programs = {
    atuin.settings.sync_address = "http://theta:8888";
    git.settings.user = {
      name = "Michael van der Loo";
      email = "me@mvanderloo.com";
    };
    jujutsu.settings.user = {
      name = "Michael van der Loo";
      email = "me@mvanderloo.com";
    };
    nh.flake = "/etc/nixos";
  };
}
