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
    stateVersion = "26.05";
    username = "mv";
    homeDirectory = "/home/mv";

    packages = with pkgs; [
      rayfish
      discord
      maki
    ];
  };

  programs = {
    atuin.settings.sync_address = "http:omega:8888";
    docker-cli.enable = true;
    git = {
      userName = "Michael van der Loo";
      userEmail = "me@mvanderloo.com";
    };
    home-manager.enable = true;
    jujutsu.settings.user = {
      email = "me@mvanderloo.com";
      name = "Michael van der Loo";
    };
    ssh.settings."github.com".IdentityFile = "~/.ssh/id_ed25519";
  };
}
