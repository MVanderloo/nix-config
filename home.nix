{ pkgs, ... }:

{
  xdg.enable = true;

  home = {
    stateVersion = "26.05";
    username = "mi30175";
    homeDirectory = "/Users/mi30175";
    preferXdgDirectories = true;

    shellAliases = {
      tree = "eza --tree";
      ".." = "cd ..";
    };

    packages = with pkgs; [
      cloc
      curl
      deadnix
      docker
      duckdb
      fzf
      gawk
      gh
      glab
      gnugrep
      just
      nixd
      nixfmt
      sd
      sesh
      sl
      statix
      tmux
      unzip
      watchexec
      wget
    ];
  };

  programs = {
    atuin = {
      enable = true;
      # flags = [ "--disable-up-arrow" ];
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
      config = {
        theme = "ansi";
      };
      # TODO configure fully
      # extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];
      # syntaxes = ;
    };
    btop.enable = true; # TODO configure
    delta = {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
      # TODO set options
      options = { };
    };
    # devenv.enable = false;
    dircolors = {
      enable = true;
      enableFishIntegration = true;
    };
    direnv = {
      enable = true;
      enableFishIntegration = true;
      # nix-direnv.enable = true; # TODO try this
    };
    docker-cli.enable = false;
    eza = {
      enable = true;
      enableFishIntegration = true;
      # TODO check all these options
      colors = "auto";
      icons = "auto";
      extraOptions = [
        "--classify"
        "--group-directories-first"
        "--time-style=long-iso"
        "--group"
        "--color-scale=size"
      ];
    };
    fd = {
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
    fish = {
      enable = true;
      interactiveShellInit = ''
        fish_vi_cursor
      '';
      functions = {
        fish_greeting.body = "";
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
    fastfetch.enable = true;
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
    gh.enable = false;
    gh-dash.enable = false;
    ghostty.enable = false;
    git.enable = false;
    gpg.enable = false;
    # home-manager.enable = true;
    jq.enable = true;
    jujutsu = {
      enable = true;
      ediff = true;
      settings = {
        user = {
          email = "me@mvanderloo.com";
          name = "Michael van der Loo";
        };
        ui = {
          default-command = "logstatus";
          editor = "nvim";
          # pager = [ "less" "-SFRX" ];
        };
        git.push-new-bookmarks = true;
        aliases = {
          rebase-all = [
            "rebase"
            "-s"
            "(::trunk())+ & mutable()"
            "-d"
            "trunk()"
          ];
          accuse = [
            "file"
            "annotate"
          ];
          logstatus = [
            "log"
            "-T"
            "log_with_current_files"
          ];
        };
        template-aliases.log_with_current_files = "builtin_log_compact ++ if(current_working_copy, diff.summary())";
      };
    };
    lazygit.enable = true;
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
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      vimdiffAlias = true;
      sideloadInitLua = true;
    };
    pi-coding-agent = {
      enable = true;
    };
    ripgrep = {
      enable = true;
      # TODO this doesn't seem to work
      # arguments = [
      #   "--max-columns=150"
      #   "--max-columns-preview"
      #   "--smart-case"
      # ];
    };
    sesh = {
      enable = false;
    };
    # ssh = {
    #   enable = true;
    #   enableDefaultConfig = false;
    #   settings."*" = {
    #     ForwardAgent = true;
    #     AddKeysToAgent = "yes";
    #     Compression = true;
    #     ServerAliveInterval = 0;
    #     ServerAliveCountMax = 3;
    #     HashKnownHosts = false;
    #     UserKnownHostsFile = "~/.ssh/known_hosts";
    #     ControlMaster = "yes";
    #     ControlPath = "~/.ssh/master-%r@%n:%p";
    #     ControlPersist = "no";
    #   };
    # };
    starship = {
      enable = true;
      enableFishIntegration = true;
      presets = [ "nerd-font-symbols" ];
      extraPackages = [ pkgs.jj-starship ];
    };
    tealdeer = {
      enable = true;
    };
    tmux = {
      enable = false;
    };
    yazi = {
      enable = true;
      enableFishIntegration = true;
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };
    # jankyborders = {
    #   enable = true;
    #   settings = {
    #     style = "round";
    #     width = 6.0;
    #     hidpi = "off";
    #     active_color = "0xFFFFFFFF"; #"0xffe2e2e3";
    #     inactive_color = "0x00000000"; # "0xff414550";
    #   };
    # };
  };

  programs.aerospace = {
    enable = false;

    settings = {
      key-mapping = {
        preset = "qwerty";
      };

      # https://nikitabobko.github.io/AeroSpace/guide#normalization
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      default-root-container-layout = "tiles";
      default-root-container-orientation = "horizontal";

      # Mouse follows focus when focused monitor changes
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
      automatically-unhide-macos-hidden-apps = true;

      gaps = {
        inner = {
          horizontal = 8;
          vertical = 8;
        };

        outer = {
          left = 4;
          bottom = 4;
          top = 4;
          right = 4;
        };
      };

      mode = {
        main = {
          binding = {
            cmd-r = "reload-config";
            cmd-enter = "exec-and-forget open -n /Applications/Ghostty.app/";
            cmd-t = "exec-and-forget open -n /Applications/Ghostty.app/";
            cmd-b = "exec-and-forget open -na \"Google Chrome\"";
            cmd-d = "exec-and-forget open -a Raycast";

            cmd-slash = "layout tiles horizontal vertical";
            cmd-shift-slash = "layout accordion horizontal vertical";

            cmd-w = "close";

            cmd-h = "focus left";
            cmd-j = "focus down";
            cmd-k = "focus up";
            cmd-l = "focus right";

            cmd-semicolon = "macos-native-minimize";

            cmd-shift-h = "move left";
            cmd-shift-j = "move down";
            cmd-shift-k = "move up";
            cmd-shift-l = "move right";

            cmd-alt-h = "join-with left";
            cmd-alt-j = "join-with down";
            cmd-alt-k = "join-with up";
            cmd-alt-l = "join-with right";

            cmd-f = "fullscreen";
            cmd-shift-f = "macos-native-fullscreen";

            cmd-comma = "workspace prev";
            cmd-shift-comma = "move-node-to-workspace --focus-follows-window prev";
            cmd-period = "workspace next";
            cmd-shift-period = "move-node-to-workspace --focus-follows-window next";

            cmd-1 = "workspace 1";
            cmd-2 = "workspace 2";
            cmd-3 = "workspace 3";
            cmd-4 = "workspace 4";
            cmd-5 = "workspace 5";
            cmd-6 = "workspace 6";
            cmd-7 = "workspace 7";
            cmd-8 = "workspace 8";
            cmd-9 = "workspace 9";
            cmd-0 = "workspace 10";

            cmd-shift-1 = "move-node-to-workspace 1";
            cmd-shift-2 = "move-node-to-workspace 2";
            cmd-shift-3 = "move-node-to-workspace 3";
            cmd-shift-4 = "move-node-to-workspace 4";
            cmd-shift-5 = "move-node-to-workspace 5";
            cmd-shift-6 = "move-node-to-workspace 6";
            cmd-shift-7 = "move-node-to-workspace 7";
            cmd-shift-8 = "move-node-to-workspace 8";
            cmd-shift-9 = "move-node-to-workspace 9";
            cmd-shift-0 = "move-node-to-workspace 10";

            cmd-e = "balance-sizes";
            cmd-shift-r = "mode resize";
          };
        };

        resize = {
          binding = {
            h = "resize width -50";
            j = "resize height +50";
            k = "resize height -50";
            l = "resize width +50";

            cmd-shift-r = "mode main";
            esc = "mode main";
          };
        };
      };
    };
  };
}
