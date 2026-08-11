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
      diffnav
      dust
      findutils
      gawk
      git-filter-repo
      glab
      gnugrep
      gnused
      just
      openssh
      prek
      rename
      rsync
      sd
      sl
      tmux
      tuicr
      tuxedo
      unzip
      watchexec
      wget
      worktrunk
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
      options = {
        syntax-theme = "ansi";
        navigate = true;
        max-line-distance = 1;
        relative-paths = true;
        inspect-raw-lines = false;

        hyperlinks = true;
        hyperlinks-file-link-format = "nvim +{line} {path}";

        zero-style = "dim normal";
        plus-style = "green normal";
        plus-emph-style = "brightgreen normal reverse";
        plus-non-emph-style = "green";
        minus-style = "red normal";
        minus-emph-style = "brightred normal reverse";
        minus-non-emph-style = "red";

        file-style = "bold";
        hunk-header-style = "omit";
        hunk-header-file-style = "normal";
        hunk-header-line-number-style = "normal";

        line-numbers = true;
        line-numbers-left-style = "normal";
        line-numbers-right-style = "normal";
        line-numbers-minus-style = "red";
        line-numbers-plus-style = "green";
        line-numbers-zero-style = "dim normal";

        side-by-side = false;
        line-numbers-left-format = " {nm:>}│";
        line-numbers-right-format = "{np:<} │";

        # side-by-side = true;
        # line-numbers-left-format = " {nm} │ ";
        # line-numbers-right-format = "│ {np} │";

        blame-code-style = "syntax";
        blame-palette = "normal";
        blame-format = "{author} - {timestamp}";
      };
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
    git = {
      enable = true;
      ignores = [
        "*.env"
        ".DS_Store"
        "Thumbs.db"
      ];
      settings = {
        aliases = {
          co = "checkout";
          sm = "submodule";
          sw = "switch";
          st = "status";
          graph = "log --graph --all";

          ignore = "!f() { IFS=','; curl -sL \"https://www.toptal.com/developers/gitignore/api/$*\"; }; f";

          stashgrep = "!f() { for i in $(git stash list --format='%gd'); do git stash show -p $i | grep -H --label=\"$i\" \"$@\"; done; }; f";
        };
        url = {
          "git@github.com:MVanderloo/".insteadOf = "my:";
          "git@github.com:".insteadOf = "gh:";
          "git@gitlab.com:".insteadOf = "gl:";
          "git@codeberg.org:".insteadOf = "cb:";
        };
        branch = {
          autosetupmerge = "always";
          autosetuprebase = "remote";
          sort = "-committerdate";
        };
        commit = {
          verbose = true;
          gpgSign = true;
        };
        core = {
          compression = 9;
          logAllRefUpdates = true;
          preloadindex = true;
          whitespace = "trailing-space";

          # pager = "DELTA_PAGER='less -S' delta";
        };
        diff = {
          algorithm = "histogram";
          colorMoved = "zebra";
          colorMovedWS = "allow-indentation-change";
          context = 8;
          interHunkContext = 10;
          mnemonicPrefix = true;
          renames = "copies";

          tool = "nvimdiff";
          guitool = "nvimdiff";
          prompt = false;
        };
        interactive.singleKey = true;
        difftool = {
          prompt = false;
          "nvimdiff".cmd = "nvim -d \"$LOCAL\" \"$REMOTE\"";
        };
        blame.coloring = "highlightRecent";
        advice = {
          addEmbeddedRepo = false;
          addEmptyPathspec = false;
          addIgnoredFile = false;
          amWorkDir = false;
          ambiguousFetchRefspec = false;
          checkoutAmbiguousRemoteBranchName = false;
          commitBeforeMerge = false;
          detachedHead = false;
          diverging = false;
          fetchShowForcedUpdates = false;
          forceDeleteBranch = false;
          ignoredHook = false;
          implicitIdentity = false;
          mergeConflict = false;
          nestedTag = false;
          pushAlreadyExists = false;
          pushFetchFirst = false;
          pushNeedsForce = false;
          pushNonFFCurrent = false;
          pushNonFFMatching = false;
          pushRefNeedsUpdate = false;
          pushUnqualifiedRefname = false;
          pushUpdateRejected = false;
          rebaseTodoError = false;
          refSyntax = false;
          resetNoRefresh = false;
          resolveConflict = false;
          rmHints = false;
          sequencerInUse = false;
          skippedCherryPicks = false;
          sparseIndexExpanded = false;
          statusAheadBehind = false;
          statusHints = false;
          statusUoption = false;
          submoduleAlternateErrorStrategyDie = false;
          submoduleMergeConflict = false;
          submodulesNotUpdated = false;
          suggestDetachingHead = false;
          updateSparsePath = false;
          waitingForEditor = false;
          worktreeAddOrphan = false;
        };
        format.pretty = "format:%C(yellow)%h%C(reset)%C(auto)%d%C(reset) - %C(white)%s%C(reset) %C(blue)(%ar)%C(reset) %C(dim white)- %an%C(reset)";
        init.defaultBranch = "main";
        maintenance = {
          auto = true;
          strategy = "incremental";
        };
        merge = {
          autoStash = true;
          conflictStyle = "zdiff3";
          tool = "nvimdiff";
        };

        mergetool = {
          prompt = false;
          keepBackup = false;

          "nvimdiff".layout = "LOCAL,BASE,REMOTE / MERGED";
        };
        push = {
          autoSetupRemote = true;
          default = "current";
        };

        pull.rebase = "merges";

        rerere = {
          autoUpdate = true;
          enabled = true;
        };

        rebase = {
          autoSquash = true;
          autoStash = true;
        };
        submodule = {
          fetchJobs = 0;
          recurse = true;
        };
        status = {
          branch = true;
          showStash = true;
          showUntrackedFiles = "all";
        };

        tag.sort = "-version:refname";
      };
    };
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
