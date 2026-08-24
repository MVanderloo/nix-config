{ pkgs, ... }:
{
  imports = [
    ./modules/editor.nix
    ./modules/fish.nix
    ./modules/ssh.nix
    ./modules/tmux.nix
    ./modules/version-control.nix
    ./modules/xdg.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "mv";
    homeDirectory = "/home/mv";
    stateVersion = "26.05";

    packages = with pkgs; [
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
    ssh.settings."github.com".IdentityFile = "~/.ssh/id_ed25519";
  };
}
