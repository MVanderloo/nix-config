{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      diffnav
      git-filter-repo
      glab
      prek
      tuicr
      worktrunk
    ];
  };

  programs = {
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
          gpgSign = false;
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
    jujutsu = {
      enable = true;
      # ediff = true;
      settings = {
        ui = {
          default-command = "logstatus";
          editor = "nvim";
          # pager = [ "less" "-SFRX" ];
        };
        git.push-new-bookmarks = true;
        aliases = {
          accuse = [
            "file"
            "annotate"
          ];
          logstatus = [
            "log"
            "-T"
            "log_with_current_files"
          ];
          push = [
            "git"
            "push"
          ];
          rebase-all = [
            "rebase"
            "-s"
            "(::trunk())+ & mutable()"
            "-d"
            "trunk()"
          ];
          update-branch = [
            "bookmark"
            "move"
            "--to"
            "@-"
          ];
        };
        template-aliases.log_with_current_files = "builtin_log_compact ++ if(current_working_copy, diff.summary())";
      };
    };
    lazygit = {
      enable = true;
      shellWrapperName = "lag";
    };
  };
}
