{
  config,
  ...
}: {
  programs.ghostty = {
    enable = true;
    installBatSyntax = true;
    clearDefaultKeybinds = true;
    settings = {
      quit-after-last-window-closed = true;
      confirm-close-surface = false;

      shell-integration-features = "ssh-env,ssh-terminfo,sudo";

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

      window-inherit-working-directory = false;

      keybind = [
        "super+ctrl+r=reload_config"
        "super+==increase_font_size:1"
        "super++=increase_font_size:1"
        "super+-=decrease_font_size:1"
        "super+_=decrease_font_size:1"
        "paste=paste_from_clipboard"
        "super+v=paste_from_clipboard"
      ];
    };
  };

  home.file."${config.home.homeDirectory}/.local/bin/push-ghostty-term" = {
    executable = true;
    text = ''
      #!/bin/sh
      set -eu
      hostname="''${1:?Usage: push-ghostty-term <hostname>}"
      infocmp -x xterm-ghostty | ssh "$hostname" -- tic -x -
    '';
  };
}
