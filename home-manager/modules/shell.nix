{ pkgs, ... }:
{
  home.shellAliases = {
    tree = "eza --tree";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  };

  programs = {
    atuin = {
      enable = true;
      forceOverwriteSettings = true;
      daemon.enable = true;
      settings = {
        update_check = false;

        style = "compact";
        inline_height = 15;
        show_numeric_shortcuts = false;
        max_preview_height = 4;
        show_help = false;
        show_tabs = false;
        prefers_reduced_motion = true;
        ui.columns = [
          "exit"
          "time"
          "duration"
          "command"
        ];

        search_mode = "daemon-fuzzy";
        secrets_filter = true;
        enter_accept = true;
        command_chaining = true;
        filter_mode = "host";
        search.filters = [
          "workspace"
          "host"
          "directory"
          "global"
        ];

        filter_mode_shell_up_key_binding = "session";
      };
    };
    fish = {
      enable = true;
      # TODO: cursor is not what I want
      interactiveShellInit = ''
        fish_vi_cursor
      '';
      functions = {
        fish_greeting = "";
        fish_user_keybindings = ''
          fish_default_key_bindings -M insert
          bind -M insert ctrl-p up-or-search
          bind -M insert ctrl-n down-or-search
        '';
        ls_after_cd = {
          onVariable = "PWD";
          body = "ls -a";
        };
      };
    };
    starship = {
      enable = true;
      enableFishIntegration = true;
      presets = [ "nerd-font-symbols" ];
      extraPackages = [ pkgs.jj-starship ];
    };
  };
}
