{ lib, pkgs, ... }:

let
  bbAuth = pkgs.callPackage ../../packages/bb-auth { };
  plugin = pkgs.stdenvNoCC.mkDerivation {
    pname = "noctalia-bb-auth";
    version = "1.1.1";

    src = pkgs.fetchFromGitHub {
      owner = "branrgx";
      repo = "noctalia-plugins";
      rev = "409d26d29faae6ed2fa1cbd44efba3d8f0eaa097";
      hash = "sha256-e7/A5VuzKkgp3RM1JtwfNqioi+S1SGAJ1QlUIE18Ub8=";
    };

    dontBuild = true;
    postPatch = ''
      substituteInPlace bb-auth/service.luau \
        --replace-fail '"python3 "' '"${pkgs.python3}/bin/python3 "'
      substituteInPlace bb-auth/panel.luau bb-auth/blocked.luau \
        --replace-fail '"python3",' '"${pkgs.python3}/bin/python3",' \
        --replace-fail 'noctalia.pluginDataDir()' 'noctalia.getenv("XDG_RUNTIME_DIR")'

      # Prompt responses are transient secrets. Keep the handoff in the private 
      # runtime directory, with names scoped to this plugin.
      substituteInPlace bb-auth/panel.luau \
        --replace-fail '.. filename' '.. "noctalia-bb-auth-" .. filename'
      substituteInPlace bb-auth/blocked.luau \
        --replace-fail '"/blocked-cancel.json"' '"/noctalia-bb-auth-blocked-cancel.json"'
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -r bb-auth catalog.toml "$out/"
      runHook postInstall
    '';

    meta = {
      description = "Noctalia authentication UI provider for bb-auth";
      homepage = "https://github.com/branrgx/noctalia-plugins/tree/main/bb-auth";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  };
in
{
  home.packages = [ bbAuth ];

  programs.noctalia = {
    enable = true;
    package = null;
    systemd.enable = false;

    settings = {
      bar = {
        order = [ "Status" ];
        Status = {
          background_opacity = 0.0;
          margin_edge = 0;
          margin_ends = 0;
          radius = 0;
          scale = 1.2;
          shadow = false;
          widget_spacing = 10;
        };
      };

      control_center.shortcuts = [
        { type = "wifi"; }
        { type = "bluetooth"; }
        { type = "caffeine"; }
        { type = "nightlight"; }
        { type = "notification"; }
        { type = "session"; }
      ];

      dock = {
        auto_hide = true;
        enabled = true;
        icon_size = 62;
        main_axis_padding = 20;
        reserve_space = false;
        show_dots = true;
      };

      idle = {
        behavior_order = [
          "lock"
          "screen-off"
          "suspend"
        ];
        behavior = {
          lock = {
            action = "lock";
            enabled = true;
            timeout = 300;
          };
          screen-off = {
            action = "screen_off";
            enabled = true;
            timeout = 360;
          };
          suspend = {
            action = "lock_and_suspend";
            enabled = true;
            timeout = 3600;
          };
        };
      };

      location.auto_locate = true;

      lockscreen_widgets = {
        enabled = true;
        widget = {
          clock = {
            cy = 200.0;
            output = "eDP-1";
            type = "clock";
            settings = {
              background_opacity = 0.0;
              format = "{:%H:%M}";
            };
          };
          weather = {
            cy = 880.0;
            output = "eDP-1";
            type = "weather";
            settings.background_opacity = 0.0;
          };
        };
      };

      shell = {
        corner_radius_scale = 0.0;
        font_family = "MesloLGM Nerd Font";
        niri_overview_type_to_launch_enabled = true;
        setup_wizard_enabled = false;
        animation.speed = 1.2;
        panel.transparency_mode = "glass";
      };

      theme = {
        builtin = "Catppuccin";
        templates.builtin_ids = [
          "btop"
          "gtk3"
          "gtk4"
          "ghostty"
          "niri"
          "qt"
        ];
      };

      wallpaper.directory = "${../../assets/wallpapers}";

      shell.polkit_agent = false;
      plugins = {
        enabled = [ "branrgx/bb-auth" ];
        source = [
          {
            name = "official";
            kind = "git";
            location = "https://github.com/noctalia-dev/official-plugins";
          }
          {
            name = "community";
            kind = "git";
            location = "https://github.com/noctalia-dev/community-plugins";
          }
          {
            name = "branrgx";
            kind = "path";
            location = "${plugin}";
          }
        ];
      };
    };
  };

  services.gpg-agent.pinentry = {
    package = bbAuth;
    program = "pinentry-bb";
  };

  systemd.user.services.bb-auth = {
    Unit = {
      Description = "BB Auth - Noctalia authentication backend";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      ExecStart = "${lib.getExe bbAuth} --daemon";
      Slice = "session.slice";
      Restart = "on-failure";
      RestartSec = 2;
      TimeoutStopSec = 5;
      UMask = "0077";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  xdg.dataFile = {
    "dbus-1/services/org.bb.auth.service".source =
      "${bbAuth}/share/dbus-1/services/org.bb.auth.service";
    "dbus-1/services/org.gnome.keyring.SystemPrompter.service".source =
      "${bbAuth}/share/bb-auth/org.gnome.keyring.SystemPrompter.service";
  };
}
