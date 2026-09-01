{ config, inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.preservation.nixosModules.preservation
    inputs.sops-nix.nixosModules.sops

    ../../modules/nix-settings.nix
    ../../modules/nixos/bash.nix
    ../../modules/nixos/console.nix
    ../../modules/nixos/penguin-plymouth.nix

    ./configuration.nix
    ./disk.nix
    ./hardware-configuration.nix
    ./preservation.nix
  ];

  home-manager = {
    users.mv = ./home.nix;

    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      githubSshKey = config.sops.secrets.github-ssh-key.path;
    };
  };
}
