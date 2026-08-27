{ pkgs, ... }:
{
  imports = [
    ../../home-manager/modules/editor.nix
    ../../home-manager/modules/fish.nix
    ../../home-manager/modules/identity.nix
    ../../home-manager/modules/ssh.nix
    ../../home-manager/modules/tmux.nix
    ../../home-manager/modules/version-control.nix
    ../../home-manager/modules/xdg.nix
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
    ssh.settings."github.com".IdentityFile = "~/.ssh/id_ed25519";
  };
}
