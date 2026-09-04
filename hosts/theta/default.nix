{ config, inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.preservation.nixosModules.preservation
    inputs.sops-nix.nixosModules.sops
    inputs.waylandcraft-desktop.nixosModules.default

    ../../modules/nix-settings.nix
    ../../modules/nixos/bash.nix
    ../../modules/nixos/console.nix
    ../../modules/nixos/penguin-plymouth.nix
    ../../modules/nixos/services/hermes-agent.nix

    ./configuration.nix
    ./disk.nix
    ./hardware-configuration.nix
    ./preservation.nix
    # ./services/trmnl-node-lite.nix
    ./waylandcraft.nix
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
