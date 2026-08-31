{ pkgs, ... }:
{
  imports = [
    ../modules/home-manager/editor.nix
    ../modules/home-manager/fish.nix
    ../modules/home-manager/ssh.nix
    ../modules/home-manager/tmux.nix
    ../modules/home-manager/version-control.nix
    ../modules/home-manager/xdg.nix
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
