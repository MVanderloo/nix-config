{ pkgs, ... }:
{
  # TODO: configure theta as remote builder for tau
  #   In /etc/nix/nix.conf on tau:
  #     builders = ssh-ng://theta x86_64-linux - - nixos-test,big-parallel,kvm
  #     builders-use-substitutes = true
  imports = [
    ../../home-manager/modules/editor.nix
    ../../home-manager/modules/fish.nix
    ../../home-manager/modules/identity.nix
    # ../../home-manager/modules/ghostty.nix
    ../../home-manager/modules/ssh-gpg.nix
    ../../home-manager/modules/tmux.nix
    ../../home-manager/modules/version-control.nix
    ../../home-manager/modules/xdg.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    stateVersion = "26.05";
    username = "mv";
    homeDirectory = "/home/mv";

    packages = with pkgs; [
      devenv
      discord
      maki
      rayfish
    ];
  };

  programs = {
    atuin.settings.sync_address = "http:omega:8888";
    docker-cli.enable = true;
    home-manager.enable = true;
    # ssh.settings."github.com".IdentityFile = "~/.ssh/id_ed25519";
  };
}
