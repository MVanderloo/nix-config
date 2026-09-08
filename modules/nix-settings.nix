{ lib, pkgs, ... }:

{
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      use-xdg-base-directories = true;
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 10d";
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      dates = "daily";
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      interval = [
        {
          Hour = 3;
          Minute = 15;
        }
      ];
    };
  };
}
