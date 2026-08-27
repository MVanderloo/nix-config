{ pkgs, ... }:
{
  imports = [ ../modules/ghostty.nix ];

  programs.ghostty = {
    package = pkgs.ghostty-bin;
    settings = {
      macos-titlebar-style = "hidden";
      macos-dock-drop-behavior = "window";

      macos-icon = "custom-style";
      macos-icon-frame = "plastic";
      macos-icon-ghost-color = "black";
      macos-icon-screen-color = "black";
    };
  };
}
