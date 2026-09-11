{ inputs, ... }:

{
  imports = [
    ./configuration.nix
    ./disk.nix
    ./hardware-configuration.nix
    ./preservation.nix

    ../../modules/nix-settings.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/bash.nix
    ../../modules/nixos/console.nix
    ../../modules/nixos/mosh.nix
    ../../modules/nixos/noctalia.nix
    ../../modules/nixos/penguin-plymouth.nix
    ../../modules/nixos/security.nix
    ../../modules/nixos/tailscale.nix
    ../../modules/nixos/zram-swap.nix

    inputs.disko.nixosModules.disko
    inputs.helium.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
    inputs.preservation.nixosModules.preservation
    inputs.sops-nix.nixosModules.sops
  ];

  home-manager = {
    users.mv = ./home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "delta";
        protocol = "ssh-ng";
        sshUser = "mv";
        systems = [ "x86_64-linux" ];
        maxJobs = 8;
        speedFactor = 2;
      }
      {
        hostName = "theta";
        protocol = "ssh-ng";
        sshUser = "mv";
        systems = [ "x86_64-linux" ];
        maxJobs = 8;
      }
    ];
    settings.builders-use-substitutes = true;
  };
}
