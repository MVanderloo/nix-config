{ inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager

    ../../nixos/modules/console.nix
    ../../nixos/modules/framework-penguin-plymouth.nix

    ./configuration.nix
    ./disk.nix
    ./hardware-configuration.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.mv = ./home.nix;
  };
}
