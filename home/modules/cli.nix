{ pkgs, ... }:
{
  home.packages = with pkgs; [
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
    rename
    rsync
    sd
    sl
    tuxedo
    unzip
    watchexec
    wget
  ];

  home.shellAliases = {
    tree = "eza --tree";
  };

  programs = {
    bat = {
      enable = true;
      config.theme = "ansi";
      # TODO configure fully
      # extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];
      # syntaxes = ;
    };
    btop.enable = true; # TODO configure
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
    jq.enable = true;
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
    pi-coding-agent.enable = true;
    ripgrep.enable = true;
    tealdeer.enable = true;
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
