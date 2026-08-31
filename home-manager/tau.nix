{ pkgs, ... }:
{
  # TODO: configure theta as remote builder for tau
  #   In /etc/nix/nix.conf on tau:
  #     builders = ssh-ng://theta x86_64-linux - - nixos-test,big-parallel,kvm
  #     builders-use-substitutes = true
  imports = [
    ../modules/home-manager/editor.nix
    ../modules/home-manager/fish.nix
    # ../modules/home-manager/ghostty.nix
    ../modules/home-manager/ssh-gpg.nix
    ../modules/home-manager/tmux.nix
    ../modules/home-manager/version-control.nix
    ../modules/home-manager/xdg.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    stateVersion = "26.05";
    username = "mv";
    homeDirectory = "/home/mv";

    packages = with pkgs; [
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
    # ssh.settings."github.com".IdentityFile = "~/.ssh/id_ed25519";
  };
}
