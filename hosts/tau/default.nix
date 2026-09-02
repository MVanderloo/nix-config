{
  nix.settings = {
    builders = "ssh-ng://theta x86_64-linux - - nixos-test,big-parallel,kvm";
    builders-use-substitutes = true;
  };

  imports = [
    ./home.nix

    ../../modules/home-manager/fish.nix
    ../../modules/home-manager/ghostty.nix
    ../../modules/home-manager/neovim.nix
    ../../modules/home-manager/ssh-gpg.nix
    ../../modules/home-manager/syncthing.nix
    ../../modules/home-manager/tmux.nix
    ../../modules/home-manager/version-control.nix
    ../../modules/home-manager/xdg.nix
  ];

  nixpkgs.config.allowUnfree = true;
}
