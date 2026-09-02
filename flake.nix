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
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          overlayModule
          ./hosts/theta
        ];
      };

      darwinConfigurations.work-mac = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          overlayModule
          ./hosts/work-mac
        ];
      };

      homeConfigurations = {
        "mv@tau" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux.extend overlay;
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./hosts/tau ];
        };

        "mv@delta" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux.extend overlay;
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./hosts/delta ];
        };
      };

      deploy.nodes.theta = {
        hostname = "theta";
        sshUser = "mv";
        interactiveSudo = true;

        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.theta;
        };
      };

      checks.x86_64-linux = deploy-rs.lib.x86_64-linux.deployChecks self.deploy;

      formatter = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
        sys: nixpkgs.legacyPackages.${sys}.nixfmt-tree
      );
    };
}
