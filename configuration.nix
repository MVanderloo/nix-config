{ pkgs, ... }:

{
  nix.settings.experimental-features = "nix-command flakes";
  nix.enable = false;

  system.configurationRevision = null;
  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.mi30175 = {
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
}
