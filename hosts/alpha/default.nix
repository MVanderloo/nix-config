{ inputs, sshPublicKeys, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.preservation.nixosModules.preservation
    inputs.sops-nix.nixosModules.sops

    ../../modules/nix-settings.nix
    ../../modules/nixos/bash.nix
    ../../modules/nixos/mosh.nix
    ../../modules/nixos/tailscale.nix

    ./configuration.nix
    ./digital-ocean.nix
    ./disk.nix
    ./preservation.nix
  ];

  home-manager = {
    users.mv = ./home.nix;

    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit sshPublicKeys;
    };
  };
}
