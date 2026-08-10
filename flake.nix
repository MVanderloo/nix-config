{
  description = "System configs (nix-darwin + home-manager)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:nix-darwin/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    neovim-config.url = "github:mvanderloo/neovim-config";
    neovim-config.inputs.nixpkgs.follows = "nixpkgs";

    # nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    # homebrew-core = {
    #   url = "github:homebrew/homebrew-core";
    #   flake = false;
    # };
    # homebrew-cask = {
    #   url = "github:homebrew/homebrew-cask";
    #   flake = false;
    # };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      darwin,
      # nix-homebrew,
      # homebrew-cask,
      # homebrew-core,
      ...
    }:
    {
      darwinConfigurations.work = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.mi30175 = ./home/darwin.nix;
            };
          }

          # nix-homebrew.darwinModules.nix-homebrew
          # {
          #   nix-homebrew = {
          #     enable = true;
          #     enableRosetta = true;
          #     user = "mi30175";
          #     mutableTaps = false;
          #     taps."homebrew/homebrew-cask" = homebrew-cask;
          #     # taps."homebrew/homebrew-core" = homebrew-core;
          #   };
          # }
          # {
          #   homebrew.taps = [
          #     "homebrew/homebrew-cask"
          #     # "homebrew/homebrew-core"
          #   ];
          # }
        ];
      };

      homeConfigurations = {
        arch = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./home/arch.nix ];
        };
      };

      formatter = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-linux" ] (
        sys: nixpkgs.legacyPackages.${sys}.nixfmt-tree
      );
    };
}
