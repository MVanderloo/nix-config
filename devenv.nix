{ pkgs, ... }: {
  packages = [
    pkgs.deadnix
    pkgs.nixd
    pkgs.statix
  ];

  languages.nix.enable = true;
}
