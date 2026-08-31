{ inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.preservation.nixosModules.preservation

    ../../nixos/modules/console.nix
    ../../nixos/modules/penguin-plymouth.nix

    ./configuration.nix
    ./disk.nix
    ./hardware-configuration.nix
    ./preservation.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.mv = ./home.nix;
  };
}
