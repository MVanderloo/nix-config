{
  description = "Nix Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    maki = {
      url = "github:tontinton/maki";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      darwin,
      deploy-rs,
      ...
    }:
    let
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";

      systems = [
        linuxSystem
        darwinSystem
      ];

      overlay =
        final: _:
        let
          system = final.stdenv.hostPlatform.system;

          stablePkgs = import nixpkgs-stable {
            inherit system;

            config.allowUnfreePackages = [ "open-webui" ];
          };
        in
        {
          inherit (stablePkgs) llama-cpp open-webui;
          maki = inputs.maki.packages.${system}.default;
          rayfish = final.callPackage ./packages/rayfish.nix { };
        };

      overlayModule = {
        nixpkgs.overlays = [ overlay ];
      };
    in
    {
      overlays.default = overlay;

      nixosConfigurations.theta = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        specialArgs = { inherit inputs; };
        modules = [
          overlayModule
          ./hosts/theta
        ];
      };

      darwinConfigurations.work-mac = darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = { inherit inputs; };
        modules = [
          overlayModule
          ./hosts/work-mac
        ];
      };

      homeConfigurations = {
        "mv@tau" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${linuxSystem}.extend overlay;
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./hosts/tau.nix ];
        };

        "mv@delta" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${linuxSystem}.extend overlay;
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./hosts/delta.nix ];
        };
      };

      deploy.nodes.theta = {
        hostname = "theta";
        sshUser = "mv";
        interactiveSudo = true;

        profiles.system = {
          user = "root";
          path = deploy-rs.lib.${linuxSystem}.activate.nixos self.nixosConfigurations.theta;
        };
      };

      checks.${linuxSystem} = deploy-rs.lib.${linuxSystem}.deployChecks self.deploy;

      formatter = nixpkgs.lib.genAttrs systems (sys: nixpkgs.legacyPackages.${sys}.nixfmt-tree);
    };
}
