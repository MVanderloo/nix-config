{
  description = "Work Mac";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs }:
  {
    darwinConfigurations.work =
      nix-darwin.lib.darwinSystem {
        modules = [
          ./configuration.nix

          home-manager.darwinModules.home-manager
          {
            home-manager.users.mi30175 = import ./home.nix;
          }
        ];
      };
  };
}
