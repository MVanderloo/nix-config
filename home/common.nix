{ pkgs, ... }:

{
  xdg.enable = true;

  home = {
    stateVersion = "26.05";

    packages = with pkgs; [
      cloc
      curl
      deadnix
      docker
      duckdb
      gawk
      glab
      gnugrep
      just
      nixd
      nixfmt
      sd
      sl
      statix
      unzip
      watchexec
      wget
    ];
  };

  programs = {
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
    gh.enable = false;
    gh-dash.enable = false;
    git.enable = false;
    gpg.enable = false;
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
    sesh.enable = false;
    starship = {
      enable = true;
      enableFishIntegration = true;
      presets = [ "nerd-font-symbols" ];
      extraPackages = [ pkgs.jj-starship ];
    };
    tealdeer.enable = true;
    tmux.enable = false;
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
