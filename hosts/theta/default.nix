{ inputs, ... }:

{
  imports = [
    # inputs.waylandcraft-desktop.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.preservation.nixosModules.preservation
    inputs.quadlet-nix.nixosModules.quadlet
    inputs.sops-nix.nixosModules.sops

    ../../modules/nix-settings.nix
    ../../modules/nixos/bash.nix
    ../../modules/nixos/console.nix
    ../../modules/nixos/mosh.nix
    ../../modules/nixos/penguin-plymouth.nix
    ../../modules/nixos/tailscale.nix

    ./configuration.nix
    ./disk.nix
    ./hardware-configuration.nix
    ./preservation.nix
    # ./waylandcraft.nix

    # ./services/trmnl-node-lite.nix
    ./services/hermes-agent.nix
    ./services/home-assistant.nix
    ./services/homepage.nix
  ];

  home-manager = {
    users.mv = ./home.nix;

    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
