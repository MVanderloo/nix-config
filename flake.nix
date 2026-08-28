{
  description = "Nix Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-stable.inputs = { };

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:nix-darwin/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    maki.url = "github:tontinton/maki";
    maki.inputs.nixpkgs.follows = "nixpkgs-stable";
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      darwin,
      disko,
      maki,
      ...
    }:
    let
      packages =
        final: prev:
        let
          stablePkgs = import nixpkgs-stable {
            system = prev.system;
            config.allowUnfree = true;
          };
        in
        {
          llama-cpp = stablePkgs.llama-cpp.override {
            nodejs = stablePkgs.nodejs.overrideAttrs (_: {
              doCheck = false;
            });
          };
          maki = maki.packages.${prev.system}.default;
          nodejs = prev.nodejs.overrideAttrs (_: {
            doCheck = false;
          });
          open-webui = stablePkgs.open-webui;
          rayfish = final.callPackage ./packages/rayfish.nix { };
        };
    in
    {
      nixosConfigurations.theta = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/theta ];
      };

      darwinConfigurations.work-mac = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs packages; };
        modules = [ ./hosts/work-mac ];
      };

      homeConfigurations = {
        tau = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux.extend packages;
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./home-manager/tau.nix ];
        };

        delta = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux.extend packages;
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./home-manager/delta.nix ];
        };
      };

      formatter = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-linux" ] (
        sys: nixpkgs.legacyPackages.${sys}.nixfmt-tree
      );
    };
}
