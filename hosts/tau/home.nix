{ config, pkgs, ... }:

{
  home = {
    stateVersion = "26.05";
    username = "mv";
    homeDirectory = "/home/mv";

    packages = with pkgs; [
      codex
      devenv
      maki
      rayfish
      vesktop
    ];
  };

  programs = {
    atuin.settings.sync_address = "http:omega:8888";
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
    # ssh.settings."github.com".IdentityFile = "~/.ssh/id_ed25519";
  };
}
