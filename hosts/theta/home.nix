{
  config,
  githubSshKey,
  pkgs,
  ...
}:
{
  imports = [
    ../../home-manager/modules/bash.nix
    ../../home-manager/modules/editor.nix
    ../../home-manager/modules/fish.nix
    ../../home-manager/modules/ssh.nix
    ../../home-manager/modules/tmux.nix
    ../../home-manager/modules/version-control.nix
    ../../home-manager/modules/xdg.nix
  ];

  home = {
    username = "mv";
    homeDirectory = "/home/mv";
    stateVersion = "26.05";

    packages = with pkgs; [
      codex
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
    nh = {
      enable = true;
      flake = "${config.home.homeDirectory}/nix-config";
    };
    ssh.settings."github.com" = {
      IdentityFile = githubSshKey;
      IdentitiesOnly = true;
    };
  };
}
