{
  config,
  lib,
  ...
}:
let
  # Noctalia v5 can load many TOML fragments. Replace the old dotfile links
  # with inert managed files now that the complete config lives in config.toml.
  legacyConfigFiles = [
    "hooks.toml"
    "keybinds.toml"
    "lockscreen.toml"
    "notifications.toml"
    "osd.toml"
    "services.toml"
    "shell.toml"
    "user-templates.toml"
    "wallpaper.toml"
  ];
in
{
  programs.noctalia = {
    enable = true;

    # Keep using Arch's noctalia-git package. In particular, this preserves
    # the existing PAM integration and the exact v5 build currently in use.
    package = null;
    systemd.enable = false;

    settings = {
      audio = {
        enable_overdrive = false;
        enable_sounds = false;
        notification_sound = "";
        sound_volume = 0.5;
        volume_change_sound = "";
      };

      backdrop = {
        blur_intensity = 0.5;
        enabled = false;
        tint_intensity = 0.3;
      };

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

      brightness.enable_ddcutil = false;

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

      idle.behavior = {
        lock = {
          command = "noctalia:session lock";
          enabled = true;
          timeout = 300;
        };
        screen-off = {
          command = "noctalia:dpms-off";
          enabled = true;
          resume_command = "noctalia:dpms-on";
          timeout = 360;
        };
      };

      keybinds = {
        cancel = [ "escape" ];
        down = [ "down" ];
        left = [ "left" ];
        right = [ "right" ];
        tab_next = [ "tab" ];
        tab_previous = [ "shift+iso_left_tab" ];
        up = [ "up" ];
        validate = [
          "return"
          "kp_enter"
          "space"
        ];
      };

      location = {
        address = "";
        auto_locate = true;
      };

      lockscreen = {
        allow_empty_password = false;
        blur_intensity = 0.5;
        blurred_desktop = false;
        enabled = true;
        fingerprint = true;
        monitors = [ ];
        tint_intensity = 0.3;
        wallpaper = "";
      };

      lockscreen_widgets = {
        enabled = true;
        schema_version = 2;
        widget_order = [
          "lockscreen-login-box@DP-1"
          "clock"
          "weather"
        ];

        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };

        widget = {
          clock = {
            box_height = 0.0;
            box_width = 0.0;
            cx = 960.0;
            cy = 200.0;
            output = "eDP-1";
            rotation = 0.0;
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
            rotation = 0.0;
            type = "login_box";
            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              input_opacity = 1.0;
              input_radius = 6.0;
              show_caps_lock = true;
              show_keyboard_layout = true;
              show_login_button = true;
              show_password_hint = true;
            };
          };

          weather = {
            box_height = 0.0;
            box_width = 0.0;
            cx = 960.0;
            cy = 880.0;
            output = "eDP-1";
            rotation = 0.0;
            type = "weather";
            settings.background_opacity = 0.0;
          };
        };
      };

      nightlight = {
        enabled = false;
        force = false;
        temperature_day = 6500;
        temperature_night = 4000;
      };

      notification = {
        background_opacity = 0.97;
        enable_daemon = true;
        layer = "top";
        offset_x = 20;
        offset_y = 8;
        scale = 1.0;
        show_actions = true;
        show_app_name = true;
      };

      osd = {
        background_opacity = 0.97;
        offset_x = 20;
        offset_y = 8;
        orientation = "horizontal";
        position = "top_right";
        position_vertical = "top_center";
        scale = 1.0;
        kinds = {
          bluetooth = true;
          brightness = true;
          caffeine = true;
          dnd = true;
          keyboard_layout = true;
          lock_keys = true;
          nightlight = true;
          power_profile = true;
          privacy = true;
          volume = true;
          volume_input = true;
          volume_output = true;
          wifi = true;
        };
      };

      shell = {
        app_icon_colorize = false;
        clipboard_auto_paste = "auto";
        clipboard_confirm_clear_history = true;
        clipboard_enabled = true;
        clipboard_history_max_entries = 100;
        clipboard_image_action_command = "";
        corner_radius_scale = 0.0;
        date_format = "%A, %x";
        font_family = "MesloLGM Nerd Font";
        middle_click_opens_widget_settings = true;
        niri_overview_type_to_launch_enabled = true;
        offline_mode = false;
        password_style = "default";
        polkit_agent = false;
        settings_show_advanced = false;
        setup_wizard_enabled = true;
        shared_gl_context = true;
        show_location = true;
        telemetry_enabled = false;
        time_format = "{:%H:%M}";
        ui_scale = 1.0;

        animation = {
          enabled = true;
          speed = 1.2;
        };

        launcher = {
          app_grid = false;
          categories = true;
          compact = false;
          session_search = false;
          show_icons = true;
          sort_by_usage = true;
        };

        panel = {
          borders = true;
          clipboard_placement = "floating";
          clipboard_position = "center";
          control_center_placement = "attached";
          launcher_placement = "floating";
          launcher_position = "center";
          session_placement = "attached";
          shadow = true;
          transparency_mode = "glass";
          wallpaper_placement = "attached";
        };

        privacy = {
          cam_filter_regex = "";
          mic_filter_regex = "";
          screen_filter_regex = "";
        };

        screen_corners = {
          enabled = false;
          size = 32;
        };

        screenshot = {
          confirm_region = false;
          copy_to_clipboard = true;
          directory = "";
          filename_pattern = "screenshot_%Y%m%d_%H%M%S";
          freeze_screen = false;
          pipe_command = "";
          pipe_to_command = false;
          save_to_file = true;
        };

        shadow = {
          alpha = 0.55;
          direction = "down";
        };
      };

      system.monitor = {
        cpu_poll_seconds = 2.0;
        disk_poll_seconds = 10.0;
        enabled = true;
        gpu_poll_seconds = 5.0;
        memory_poll_seconds = 2.0;
        network_poll_seconds = 3.0;
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
        directory = "${config.home.homeDirectory}/Pictures/aesthetic-wallpapers/images";
        edge_smoothness = 0.3;
        enabled = true;
        fill_color = "";
        fill_mode = "crop";
        transition = [
          "fade"
          "wipe"
          "disc"
          "stripes"
          "zoom"
          "honeycomb"
        ];
        transition_duration = 1500;
        transition_on_startup = false;

        automation = {
          enabled = false;
          interval_seconds = 1800;
          order = "random";
          recursive = true;
        };

        default.path = "${config.home.homeDirectory}/Pictures/aesthetic-wallpapers/images/mecha-nostalgia.png";
        last.path = "${config.home.homeDirectory}/Pictures/aesthetic-wallpapers/images/mecha-nostalgia.png";
        monitors."DP-1".path =
          "${config.home.homeDirectory}/Pictures/aesthetic-wallpapers/images/mecha-nostalgia.png";
      };

      weather = {
        effects = true;
        enabled = true;
        refresh_minutes = 30;
        unit = "celsius";
      };
    };
  };

  xdg.configFile =
    lib.genAttrs (map (name: "noctalia/${name}") legacyConfigFiles) (_: {
      force = true;
      text = "# Configuration is managed by Home Manager in config.toml.\n";
    })
    // {
      "noctalia/config.toml".force = true;
    };
}
