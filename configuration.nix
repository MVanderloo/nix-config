{ pkgs, ... }:

{
  nix.settings.experimental-features = "nix-command flakes";

  system.stateVersion = 6;
  system.primaryUser = "mi30175";

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.mi30175 = {
    home = "/Users/mi30175";
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
  homebrew.enable = true;
}
