{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    enableFishIntegration = true;
    installBatSyntax = true;
    clearDefaultKeybinds = true;
    settings = {
      quit-after-last-window-closed = true;
      confirm-close-surface = false;

      font-feature = [
        "ss01"
        "ss02"
        "ss03"
        "ss04"
        "ss05"
        "ss06"
        "ss07"
        "ss08"
        "ss09"
        "calt"
        "liga"
      ];

      window-padding-x = 8;
      window-padding-y = 8;

      macos-titlebar-style = "hidden";
      macos-dock-drop-behavior = "window";

      macos-icon = "custom-style";
      macos-icon-frame = "plastic";
      macos-icon-ghost-color = "black";
      macos-icon-screen-color = "black";

      window-inherit-working-directory = false;

      keybind = [
        "super+ctrl+r=reload_config"
        "super+==increase_font_size:1"
        "super++=increase_font_size:1"
        "super+-=decrease_font_size:1"
        "paste=paste_from_clipboard"
        "super+v=paste_from_clipboard"
      ];
    };
  };
}
