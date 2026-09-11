{
  description = "Nix Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
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

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";

    # waylandcraft-desktop.url = "path:/home/mv/waylandcraft-desktop";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      darwin,
      deploy-rs,
      quadlet-nix,
      ...
    }:
    let
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      forAllSystems = nixpkgs.lib.genAttrs [
        linuxSystem
        darwinSystem
      ];

      secrets = {
        adminPassword = ./secrets/admin-password.yaml;
        alphaPocketId = ./secrets/alpha-pocket-id.yaml;
        thetaHermes = ./secrets/theta-hermes.yaml;
        thetaTrmnl = ./secrets/theta-trmnl.yaml;
      };

      localOverlay = import ./packages {
        inherit (inputs) neovim-nightly;
      };
      overlayModule = {
        nixpkgs.overlays = [ localOverlay ];
      };
      linuxPkgs = nixpkgs.legacyPackages.${linuxSystem}.extend localOverlay;
      darwinPkgs = nixpkgs.legacyPackages.${darwinSystem}.extend localOverlay;

      mkNixos =
        module:
        nixpkgs.lib.nixosSystem {
          system = linuxSystem;
          specialArgs = { inherit inputs secrets; };
          modules = [
            overlayModule
            module
            quadlet-nix.nixosModules.quadlet
          ];
        };

      mkDarwin =
        module:
        darwin.lib.darwinSystem {
          system = darwinSystem;
          specialArgs = { inherit inputs; };
          modules = [
            overlayModule
            module
          ];
        };

      mkHome =
        module:
        home-manager.lib.homeManagerConfiguration {
          pkgs = linuxPkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [ module ];
        };
    in
    {
      overlays.default = localOverlay;

      apps = forAllSystems (system: {
        deploy = deploy-rs.apps.${system}.default // {
          meta.description = "Deploy this flake with deploy-rs";
        };
      });

      packages.${linuxSystem} = {
        inherit (linuxPkgs)
          neovim-head
          rayfish
          sops
          ;
      };
      packages.${darwinSystem} = {
        inherit (darwinPkgs)
          neovim-head
          sops
          ;
      };

      nixosConfigurations = {
        alpha = mkNixos ./hosts/alpha;
        tau = mkNixos ./hosts/tau;
        theta = mkNixos ./hosts/theta;
      };

      darwinConfigurations = {
        work-mac = mkDarwin ./hosts/work-mac;
      };

      homeConfigurations."mv@delta" = mkHome ./hosts/delta;

      deploy = import ./deploy.nix {
        inherit deploy-rs;
        inherit (self) homeConfigurations nixosConfigurations;
      };

      checks.${linuxSystem} = deploy-rs.lib.${linuxSystem}.deployChecks self.deploy;

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
