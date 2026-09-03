{ pkgs, ... }:

let
  nvidiaVersion = "610.57.04";
  nvidiaSha256 = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
  nvidiaDriver =
    (pkgs.linuxPackages.nvidiaPackages.mkDriver {
      version = nvidiaVersion;
      sha256_64bit = nvidiaSha256;
      sha256_aarch64 = nvidiaSha256;
      useSettings = false;
      usePersistenced = false;
    }).override
      {
        libsOnly = true;
      };
  steamWithNvidia32 = pkgs.steam.override {
    # Home Manager's generic-Linux GPU module currently exposes only the
    # native driver. Steam's 32-bit bootstrap needs the matching lib32 output.
    extraLibraries = steamPkgs:
      if steamPkgs.stdenv.hostPlatform.is32bit then [ nvidiaDriver.lib32 ] else [ ];
  };
in

{
  home.packages = [ steamWithNvidia32 ];

  nixpkgs.config = {
    nvidia.acceptLicense = true;
    allowUnfreePackages = [
      "nvidia-x11"
      "steam"
      "steam-unwrapped"
    ];
  };

  targets.genericLinux.gpu = {
    enable = true;
    nvidia = {
      enable = true;
      version = nvidiaVersion;
      sha256 = nvidiaSha256;
    };
  };
}
