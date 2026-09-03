{
  config,
  githubSshKey,
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
    ../../modules/home-manager/version-control.nix
    ../../modules/home-manager/xdg.nix
  ];

  home = {
    username = "mv";
    homeDirectory = "/home/mv";
    stateVersion = "26.05";

    packages = with pkgs; [
      devenv
      opencode
    ];
  };

  programs = {
    atuin.settings.sync_address = "http:localhost:8888";
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
    ssh.settings."github.com" = {
      IdentityFile = githubSshKey;
      IdentitiesOnly = true;
    };
  };
}
