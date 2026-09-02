{ pkgs, ... }:

{
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

  nix = {
    package = pkgs.nix;
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "theta";
        protocol = "ssh-ng";
        systems = [ "x86_64-linux" ];
        sshUser = "mv";
        maxJobs = 8;
        supportedFeatures = [
          "benchmark"
          "big-parallel"
          "kvm"
          "nixos-test"
        ];
      }
    ];
    settings.builders-use-substitutes = true;
  };
}
