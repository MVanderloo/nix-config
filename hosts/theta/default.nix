{ config, inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.preservation.nixosModules.preservation
    inputs.sops-nix.nixosModules.sops

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
    extraSpecialArgs = {
      inherit inputs;
      githubSshKey = config.sops.secrets.github-ssh-key.path;
    };
    users.mv = ./home.nix;
  };
}
