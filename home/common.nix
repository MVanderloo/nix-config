{ inputs, pkgs, ... }:
{
  xdg.enable = true;

  home = {
    stateVersion = "26.05";
    preferXdgDirectories = true;

    packages = with pkgs; [
      choose
      cloc
      coreutils
      curl
      dust
      findutils
      gawk
      git-filter-repo
      glab
      gnugrep
      gnused
      just
      openssh
      rename
      sd
      sl
      tmux
      unzip
      watchexec
      wget
      inputs.neovim-config.packages.${pkgs.system}.default
    ];

    shellAliases = {
      tree = "eza --tree";
      vim = "nvim";
      vimdiff = "nvim -d";
      ".." = "cd ..";
      "..." = "cd ...";
      "...." = "cd ....";
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  services = {
    ssh-agent.enable = false;
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
    dircolors = {
      enable = true;
      enableFishIntegration = true;
    };
    direnv = {
      enable = true;
      enableFishIntegration = true;
      # nix-direnv.enable = true; # TODO try this
    };
    eza = {
      enable = true;
      colors = "auto"; # does this do anything?
      enableFishIntegration = true;
      # TODO check all these options
      icons = "auto";
      extraOptions = [
        "--classify"
        "--group-directories-first"
        "--time-style=long-iso"
        "--group"
        "--color-scale=size"
      ];
    };
    fastfetch.enable = true;
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
    fish = {
      enable = true;
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
    gh = {
      enable = true;
      settings.protocol = "ssh";
    };
    gh-dash.enable = false;
    git.enable = false;
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
    # neovim = {
    #   enable = true;
    #   defaultEditor = true;
    #   vimAlias = true;
    #   vimdiffAlias = true;
    #   sideloadInitLua = true;
    # };
    pi-coding-agent.enable = true;
    ripgrep.enable = true;
    sesh.enable = false;
    starship = {
      enable = true;
      enableFishIntegration = true;
      presets = [ "nerd-font-symbols" ];
      extraPackages = [ pkgs.jj-starship ];
    };
    tealdeer.enable = true;
    tmux.enable = false;
    yazi = {
      enable = true;
      enableFishIntegration = true;
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
