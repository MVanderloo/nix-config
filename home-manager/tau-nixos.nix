{ pkgs, ... }:
{
  imports = [
    ./modules/cli.nix
    ./modules/editor.nix
    ./modules/shell.nix
    ./modules/ssh.nix
    ./modules/tmux.nix
    ./modules/version-control.nix
    ./modules/xdg.nix
  ];

  home = {
    stateVersion = "26.05";
    username = "mv";
    homeDirectory = "/home/mv";

    packages = with pkgs; [
      rayfish
      maki
    ];
  };

  programs = {
    atuin.settings.sync_address = "http:omega:8888";
    docker-cli.enable = true;
    home-manager.enable = true;
  };
}
