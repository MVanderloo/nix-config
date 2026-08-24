{ pkgs, ... }:
{
  # TODO: configure theta as remote builder for tau
  #   In /etc/nix/nix.conf on tau:
  #     builders = ssh-ng://theta x86_64-linux - - nixos-test,big-parallel,kvm
  #     builders-use-substitutes = true
  imports = [
    ./modules/editor.nix
    ./modules/fish.nix
    # ./modules/ghostty.nix
    ./modules/ssh-gpg.nix
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
