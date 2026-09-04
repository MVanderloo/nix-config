{ lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "discord-unwrapped"
    ];

  programs.waylandcraft-desktop = {
    enable = true;
    offerTtySession = true;
    extraPackages = with pkgs; [
      discord
      firefox
      ghostty
      obs-studio
      prismlauncher
    ];
  };

  services.displayManager.ly = {
    enable = true;
    x11Support = false;
  };
}
