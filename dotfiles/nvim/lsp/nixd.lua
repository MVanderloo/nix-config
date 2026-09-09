return {
  settings = {
    nixd = {
      nixpkgs = {
        expr = [[
          let
            flake = builtins.getFlake (toString ./.);
          in
            flake.inputs.nixpkgs.legacyPackages.${builtins.currentSystem}
        ]],
      },

      options = {
        ['home-manager'] = {
          expr = [[
            let
              flake = builtins.getFlake (toString ./.);
            in
              (flake.inputs.home-manager.lib.homeManagerConfiguration {
                pkgs = flake.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};
                modules = [ {
                  home = {
                    username = builtins.getEnv "USER";
                    homeDirectory = builtins.getEnv "HOME";
                    stateVersion = "26.05";
                  };
                } ];
              }).options
          ]],
        },
      },
    },
  },
}
