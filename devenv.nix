{ pkgs, ... }: {
  packages = [
    pkgs.deadnix
    pkgs.nixd
    pkgs.sops
    pkgs.ssh-to-age
    pkgs.statix
  ];

  languages.nix.enable = true;
}
