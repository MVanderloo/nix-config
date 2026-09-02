{ pkgs, ... }: {
  packages = [
    pkgs.deadnix
    pkgs.deploy-rs
    pkgs.nixd
    pkgs.sops
    pkgs.ssh-to-age
    pkgs.statix
  ];

  languages.nix.enable = true;
}
