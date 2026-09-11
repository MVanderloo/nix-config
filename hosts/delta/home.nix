{
  config,
  pkgs,
  ...
}:

{
  home = {
    stateVersion = "26.05";
    username = "mv";
    homeDirectory = "/home/mv";

    packages = with pkgs; [
      mosh
      podman-compose
      rayfish
      uv
    ];

    sessionVariables.LOCAL_KEY = "${config.xdg.configHome}/nix/alpha-deploy.sec";
  };

  wayland.windowManager.niri = {
    settings.input = {
      keyboard = {
        xkb.options = "caps:ctrl_modifier";
        repeat-delay = 200;
        repeat-rate = 20;
      };

      mouse = {
        natural-scroll = { };
        accel-speed = 0.2;
      };
    };

    # These are intentionally mutable. local.kdl is host-local and Noctalia
    # regenerates noctalia.kdl whenever its palette changes.
    extraConfig = ''
      include optional=true "local.kdl"
      include optional=true "noctalia.kdl"
    '';
  };

  programs = {
    atuin.settings.sync_address = "http://theta:8888";

    git.settings.user = {
      name = "Michael van der Loo";
      email = "me@mvanderloo.com";
    };

    jujutsu.settings.user = {
      name = "Michael van der Loo";
      email = "me@mvanderloo.com";
    };

    ghostty = {
      settings = {
        adjust-cell-height = "20%";
        adjust-cell-width = "10%";
        config-file = "?${config.home.homeDirectory}/.config/ghostty/local";
      };
      systemd.enable = true;
    };

    noctalia.settings = {
      lockscreen_widgets = {
        widget_order = [
          "lockscreen-login-box@DP-1"
          "clock"
          "weather"
        ];

        widget = {
          clock.cx = 960.0;
          weather.cx = 960.0;
          "lockscreen-login-box@DP-1" = {
            box_height = 70.0;
            box_width = 400.0;
            cx = 1280.0;
            cy = 1321.0;
            output = "DP-1";
            type = "login_box";
          };
        };
      };

      wallpaper.default.path = "${../../assets/wallpapers}/mecha-nostalgia.png";
    };

    pi-coding-agent.models.providers.ollama = {
      api = "openai-completions";
      apiKey = "ollama";
      # baseUrl = "http://localhost:8041/v1";
      baseUrl = "http://localhost:11434/v1";
      models = [
        { id = "qwen3.5:latest"; }
        { id = "gemma4:latest"; }
      ];
    };
  };

  services.syncthing.deviceName = "delta";
}
