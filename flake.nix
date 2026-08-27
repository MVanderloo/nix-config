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
        llama-cpp =
          let
            stablePkgs = nixpkgs-stable.legacyPackages.${prev.system};
          in
          stablePkgs.llama-cpp.override {
            nodejs = stablePkgs.nodejs.overrideAttrs (_: {
              doCheck = false;
            });
          };
        maki = maki.packages.${prev.system}.default;
        nodejs = prev.nodejs.overrideAttrs (_: {
          doCheck = false;
        });
        rayfish = final.callPackage ./packages/rayfish.nix { };
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
          # ./services/atuin
          # ./services/caddy
          # ./services/openwebui
          # ./services/pocket-id
          # ./services/spindle
          # ./services/tranquil-pds
          inputs."sops-nix".nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ packages ];
            sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.mv = ./home-manager/theta.nix;
            };
          }
        ];
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
