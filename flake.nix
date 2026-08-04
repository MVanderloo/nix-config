{
  description = "Work Mac";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      system = "aarch64-darwin";
      username = "mi30175";

      pkgs = import nixpkgs { inherit system; };

      homeModule = import ./home.nix;
    in
    {
      darwinConfigurations.work = nix-darwin.lib.darwinSystem {
        inherit system;

        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.users.${username} = homeModule;
          }
        ];
      };

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ homeModule ];
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
