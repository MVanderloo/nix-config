{ pkgs, ... }:

{
  xdg.enable = true;

  home = {
    stateVersion = "26.05";

    username = "mi30175";
    homeDirectory = "/Users/mi30175";

    packages = with pkgs; [
      atuin
      bat
      btop
      cloc
      curl
      deadnix
      direnv
      docker
      duckdb
      dust
      eza
      fastfetch
      fd
      fzf
      gawk
      gh
      glab
      gnugrep
      jq
      jujutsu
      just
      less
      man
      neovim
      nixd
      nixfmt
      openssh
      sd
      sesh
      sl
      starship
      statix
      tealdeer
      tmux
      unzip
      watchexec
      wget
      zoxide
    ];
  };

  programs = {
    atuin.enable = false;
    bat.enable = false;
    btop.enable = false;
    delta.enable = false;
    # devenv.enable = false;
    direnv.enable = true;
    docker-cli.enable = false;
    eza.enable = false;
    fd.enable = false;
    fish = {
      enable = true;

      shellInit = ''
        fish_add_path --move /run/current-system/sw/bin
        fish_add_path --move /nix/var/nix/profiles/default/bin
      '';
    };
    fzf.enable = false;
    gh.enable = false;
    gh-dash.enable = false;
    ghostty.enable = false;
    git.enable = false;
    gpg = {
      enable = false;
    };
    home-manager.enable = true;
    jq.enable = true;
    jujutsu.enable = true;
    lazygit.enable = true;
    man = {
      enable = true;
      generateCaches = false;
      package = pkgs.man-db;
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
  enable = true;

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
