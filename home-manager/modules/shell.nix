{ pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      choose
      cloc
      coreutils
      curl
      dust
      findutils
      gawk
      gnugrep
      gnused
      just
      pv
      readline
      rename
      rsync
      sd
      sl
      tuxedo
      unzip
      watchexec
      wget
    ];

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      tree = "eza --tree --level=3";
      trea = "eza --tree --level=3";
      ls = "eza";
      la = "eza -a";
      ll = "eza -la";
    };

    # XDG-compliant Readline config
    sessionVariables.INPUTRC = "${config.xdg.configHome}/readline/inputrc";
  };

  # TODO convert this to programs.readline config and override file
  xdg.configFile."readline/inputrc".text = ''
    # Completion menu
    TAB: menu-complete
    "\e[Z": menu-complete-backward
    set menu-complete-display-prefix on
    set show-all-if-ambiguous on
    set completion-map-case on
    set completion-ignore-case on
    set colored-stats on
    set visible-stats on
    # Suppress "Display all N possibilities?" prompt
    set completion-query-items 0
    set page-completions off
    # History search
    "\e[A": history-search-backward
    "\e[B": history-search-forward
  '';

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
    bat = {
      enable = true;
      config.theme = "ansi";
      # TODO configure fully
      # extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];
      # syntaxes = ;
    };
    btop = {
      enable = true;
      settings = {
        theme_background = true;
        vim_keys = true;
        rounded_corners = true;
        update_ms = 1000;
        base_10_sizes = false;
        background_update = true;
        base_10_bitrate = "Auto";
        graph_symbol = "braille";
        proc_sorting = "memory";
        show_battery = true;
        show_battery_watts = true;
      };
    };
    fastfetch = {
      enable = true;

      settings = {
        logo.padding.top = 2;
        display.separator = " ";
        modules = [
          "title"
          "separator"
          {
            type = "os";
            key = "{icon} OS";
            keyColor = "yellow";
            format = "{2}";
          }
          {
            type = "packages";
            key = "├󰏖";
            keyColor = "yellow";
          }
          {
            type = "terminal";
            key = "├";
            keyColor = "yellow";
          }
          {
            type = "shell";
            key = "└";
            keyColor = "yellow";
          }
          "break"
          {
            type = "host";
            key = "󰌢 PC";
            keyColor = "green";
          }
          {
            type = "cpu";
            key = "├󰻠";
            keyColor = "green";
          }
          {
            type = "gpu";
            key = "├󰍛";
            keyColor = "green";
          }
          {
            type = "disk";
            key = "├";
            keyColor = "green";
          }
          {
            type = "memory";
            key = "├󰑭";
            keyColor = "green";
          }
          {
            type = "uptime";
            key = "└󰅐";
            keyColor = "green";
          }
          "break"
          {
            type = "sound";
            key = " SOUND";
            keyColor = "cyan";
          }
          {
            type = "player";
            key = "├󰥠";
            keyColor = "cyan";
          }
          {
            type = "media";
            key = "└󰝚";
            keyColor = "cyan";
          }
          "break"
          "colors"
        ];
      };
    };
    jq.enable = true;
    dircolors.enable = true;
    direnv = {
      enable = true;
      # nix-direnv.enable = true; # TODO try this
    };
    eza = {
      enable = true;
      colors = "auto"; # does this do anything?
      # TODO check all these options
      icons = "auto";
      extraOptions = [
        "--classify"
        "--group-directories-first"
        "--time-style=long-iso"
        "--group"
        "--color-scale=size"
      ];
      # these default to true for some reason
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
      enableIonIntegration = false;
      enableNushellIntegration = false;
    };
    fd = {
      # TODO: revisit this
      # fzf ctrl-t seems to see ignored directories still
      enable = true;
      hidden = true;
      ignores = [
        ".git/"
        ".jj/"
        ".venv/"
        "node_modules/"
      ];
      extraOptions = [
        "--no-ignore-vcs"
      ];
    };
    fzf = {
      enable = true;
      defaultOptions = [
        "--border=bold"
        "--color=border:7"
        "--color=prompt:2"
        "--scrollbar=''"
        "--gutter=' '"
        "--info=inline-right"
        "--color=info:8"
        "--marker=' '"
        "--color=marker:1"
        "--pointer='󰁕'"
        "--color=pointer:9"
        "--color=label:15:bold"
        "--color=spinner:9"
        "--color=header:4"
        "--color=fg:8:bold,fg+:15,selected-fg:15:bold"
        "--color=bg:-1,bg+:-1,selected-bg:-1"
        "--color=hl:10:bold,hl+:10:bold,selected-hl:10:bold"
      ];
      historyWidget.command = ""; # use atuin
    };
    less = {
      enable = true;
      config = ''
        #command
        h left-scroll
        l right-scroll
      '';
      # options = ; # explore this
    };
    man = {
      enable = true;
      generateCaches = false;
      package = pkgs.man-db;
    };
    starship = {
      enable = true;
      presets = [ "nerd-font-symbols" ];
      extraPackages = [ pkgs.jj-starship ];
    };
    tealdeer.enable = true;
    ripgrep.enable = true;
    yazi.enable = true;
    zoxide.enable = true;
  };
}
