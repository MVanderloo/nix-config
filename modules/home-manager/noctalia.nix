{ ... }:
{
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
        widget_order = [
          "lockscreen-login-box@DP-1"
          "clock"
          "weather"
        ];
        widget = {
          clock = {
            cx = 960.0;
            cy = 200.0;
            output = "eDP-1";
            type = "clock";
            settings = {
              background_opacity = 0.0;
              format = "{:%H:%M}";
            };
          };
          "lockscreen-login-box@DP-1" = {
            box_height = 70.0;
            box_width = 400.0;
            cx = 1280.0;
            cy = 1321.0;
            output = "DP-1";
            type = "login_box";
          };
          weather = {
            cx = 960.0;
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

      wallpaper = {
        directory = "${../../assets/wallpapers}";
        default.path = "${../../assets/wallpapers}/mecha-nostalgia.png";
      };
    };
  };
}
