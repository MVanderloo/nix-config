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

    neovim-config.url = "github:mvanderloo/neovim-config";
    neovim-config.inputs.nixpkgs.follows = "nixpkgs";

    maki.url = "github:tontinton/maki";
    maki.inputs.nixpkgs.follows = "nixpkgs-stable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    tangled.url = "git+https://tangled.org/tangled.org/core";
    tangled.inputs.nixpkgs.follows = "nixpkgs-stable";
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      darwin,
      maki,
      disko,
      tangled,
      ...
    }:
    let
      packages = final: prev: {
        rayfish = final.callPackage ./packages/rayfish.nix { };
        maki = maki.packages.${prev.system}.default;
      };
    in
    {
      nixosConfigurations.theta = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # disko.nixosModules.disko
          # ./hosts/theta/disko-config.nix
          ./hosts/theta/configuration.nix
          inputs."sops-nix".nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ packages ];
            sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.mv = ./hosts/theta/home.nix;
            };
          }
        ];
      };

      darwinConfigurations.work-mac = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/work-mac/configuration.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [ packages ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.mi30175 = ./hosts/work-mac/home.nix;
            };
          }
        ];
      };

      homeConfigurations = {
        tau = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux.extend packages;
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./hosts/tau/home.nix ];
        };

        delta = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux.extend packages;
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./hosts/delta/home.nix ];
        };
      };

      formatter = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-linux" ] (
        sys: nixpkgs.legacyPackages.${sys}.nixfmt-tree
      );
    };
}
