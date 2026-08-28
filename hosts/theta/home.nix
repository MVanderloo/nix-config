{ pkgs, ... }:
{
  imports = [
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

    packages = with pkgs; [ opencode ];
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
