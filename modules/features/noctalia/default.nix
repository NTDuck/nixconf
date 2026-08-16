{
  den,
  inputs,
  ...
}: {
  den.aspects.noctalia = {
    includes = [
      # https://docs.noctalia.dev/noctalia/getting-started/nixos/#:~:text=Caution
      den.aspects.settings.networking
      den.aspects.bluetooth
      den.aspects.battery.power-profiles-daemon
      den.aspects.battery.upower
    ];

    nixos = {
      # https://docs.noctalia.dev/noctalia/getting-started/nixos/?section=binary-cache#binary-cache
      nix.settings = {
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
      };
    };

    homeManager = {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      programs.noctalia = {
        enable = true;

        settings = {
          accessibility = {
            high_contrast = false;
            ui_scale = 1.0;
          };
          audio = {
            enable_overdrive = true;
            enable_sounds = false;
            notification_sound = "";
            sound_volume = 0.5;
            volume_change_sound = "";
          };
          backdrop = {
            blur_intensity = 0.5;
            enabled = false;
            tint_intensity = 0.30000001192092896;
          };
          bar = {
            order = ["default"];
            default = {
              auto_hide = false;
              background_opacity = 0.7999999523162842;
              border = "outline";
              border_width = 0.0;
              capsule = false;
              capsule_fill = "surface_variant";
              capsule_group = [];
              capsule_opacity = 1.0;
              capsule_padding = 6.0;
              capsule_radius = 0.0;
              capsule_thickness = 0.7599999904632568;
              center = ["clock"];
              concave_edge_corners = true;
              contact_shadow = false;
              enabled = true;
              end = ["cat" "spacer_1" "notifications" "clipboard" "bar" "screenshot" "recorder" "spacer_2" "cpu" "network" "brightness" "volume" "spacer_3" "tray" "spacer_4" "battery"];
              font_weight = 500;
              hover_highlight = true;
              layer = "top";
              margin_edge = 6;
              margin_ends = 6;
              margin_opposite_edge = 0;
              padding = 14;
              panel_overlap = 0;
              position = "top";
              radius = 0;
              radius_bottom_left = 0;
              radius_bottom_right = 0;
              radius_top_left = 0;
              radius_top_right = 0;
              reserve_space = true;
              scale = 1.0;
              shadow = false;
              show_on_workspace_switch = true;
              smart_auto_hide = false;
              start = ["control-center" "spacer_5" "media" "spacer_6" "workspaces"];
              thickness = 24;
              widget_spacing = 6;
              dead_zone = {
              };
            };
          };
          battery = {
            warning_threshold = 10;
          };
          brightness = {
            enable_ddcutil = false;
            ignore_mmids = [];
            minimum_brightness = 0.0;
            sync_all_monitors = false;
          };
          calendar = {
            enabled = false;
            refresh_minutes = 15;
          };
          control_center = {
            hidden_tabs = [];
            show_session_button = true;
            show_shortcut_labels = true;
            sidebar = "compact";
            sidebar_section = "compact";
            width = 700;
            calendar = {
              event_date_format = "%A %e %B";
              event_time_format = "%H:%M";
              show_events_card = false;
              show_week_numbers = true;
            };
            shortcuts = [
              {
                type = "wifi";
              }
              {
                type = "bluetooth";
              }
              {
                type = "caffeine";
              }
              {
                type = "notification";
              }
              {
                type = "power_profile";
              }
              {
                type = "noctalia/screen_recorder:toggle";
              }
            ];
          };
          desktop_widgets = {
            enabled = false;
            schema_version = 2;
            grid = {
              cell_size = 16;
              major_interval = 4;
              visible = true;
            };
          };
          dock = {
            enabled = false;
            shadow = false;
          };
          hooks = {
            battery_charging = [];
            battery_discharging = [];
            battery_percentage_changed = [];
            battery_plugged = [];
            bluetooth_disabled = [];
            bluetooth_enabled = [];
            colors_changed = [];
            logging_out = [];
            power_profile_changed = [];
            rebooting = [];
            session_locked = [];
            session_unlocked = [];
            shutting_down = [];
            started = [];
            theme_mode_changed = [];
            wallpaper_changed = [];
            wifi_disabled = [];
            wifi_enabled = [];
          };
          hot_corners = {
            delay_ms = 0;
            enabled = false;
            bottom_left = {
              action = "none";
              command = "";
            };
            bottom_right = {
              action = "none";
              command = "";
            };
            top_left = {
              action = "none";
              command = "";
            };
            top_right = {
              action = "none";
              command = "";
            };
          };
          idle = {
            behavior_order = ["lock" "screen-off" "lock-and-suspend"];
            pre_action_fade_seconds = 0.0;
            behavior = {
              lock.enabled = false;
              lock-and-suspend.enabled = false;
              screen-off.enabled = false;
            };
          };
          keybinds = {
            cancel = ["Escape"];
            copy = ["Ctrl+c"];
            delete = ["Delete"];
            down = ["Down"];
            left = ["Left"];
            right = ["Right"];
            save = ["Ctrl+s"];
            tab_next = ["Tab"];
            tab_previous = ["Shift+ISO_Left_Tab"];
            up = ["Up"];
            validate = ["Return" "KP_Enter" "space"];
          };
          location = {
            address = "";
            auto_locate = true;
            custom_schedule = false;
            sunrise = "";
            sunset = "";
          };
          lockscreen = {
            allow_empty_password = false;
            blur_intensity = 0.4399999976158142;
            blurred_desktop = false;
            enabled = true;
            fingerprint = true;
            lock_before_suspend = true;
            monitors = [];
            tint_intensity = 0.4399999976158142;
            wallpaper = "";
          };
          lockscreen_widgets = {
            enabled = false;
            schema_version = 2;
            widget_order = ["lockscreen-login-box@eDP-1"];
            grid = {
              cell_size = 16;
              major_interval = 4;
              visible = true;
            };
            widget = {
              "lockscreen-login-box@eDP-1" = {
                box_height = 196.0;
                box_width = 810.0;
                cx = 854.0;
                cy = 885.0;
                enabled = true;
                output = "eDP-1";
                rotation = 0.0;
                type = "login_box";
                settings = {
                  background_color = "surface_variant";
                  background_opacity = 0.88;
                  background_radius = 12.0;
                  center_password_text = false;
                  input_opacity = 1.0;
                  input_radius = 6.0;
                  layout = "regular";
                  show_caps_lock = true;
                  show_keyboard_layout = true;
                  show_login_button = true;
                  show_media = true;
                  show_session_buttons = true;
                  show_unlock_hint = true;
                  show_weather = true;
                };
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
            background_opacity = 0.7999999523162842;
            border = true;
            collapse_on_dismiss = true;
            enable_daemon = true;
            history_retention_hours = 0;
            layer = "top";
            max_visible = 0;
            monitors = [];
            offset_x = 12;
            offset_y = 12;
            position = "top_right";
            scale = 1.0;
            show_actions = true;
            show_app_name = true;
          };
          osd = {
            background_opacity = 0.7999999523162842;
            border = true;
            enabled = true;
            monitors = [];
            offset_x = 12;
            offset_y = 12;
            orientation = "horizontal";
            position = "top_right";
            position_vertical = "top_right";
            scale = 1.0;
            kinds = {
              bluetooth = true;
              brightness = true;
              caffeine = true;
              dnd = true;
              keyboard_backlight = true;
              keyboard_layout = true;
              lock_keys = true;
              media = true;
              nightlight = true;
              power_profile = true;
              privacy = true;
              volume = true;
              volume_input = true;
              volume_output = true;
              wifi = true;
            };
          };
          plugin_settings = {
          };
          plugins = {
            auto_update = true;
            enabled = ["coder/deepseek_usage" "noctalia/bongocat" "avivbintangaringga/nix-monitor" "yuuto/calculator" "noctalia/screen_recorder"];
            source = [
              {
                enabled = true;
                kind = "git";
                location = "https://github.com/noctalia-dev/official-plugins";
                name = "official";
              }
              {
                enabled = true;
                kind = "git";
                location = "https://github.com/noctalia-dev/community-plugins";
                name = "community";
              }
            ];
          };
          shell = {
            app_icon_colorize = false;
            avatar_path = "${inputs.self}/assets/wallpapers/avatars/default.png";
            button_borders = true;
            card_borders = true;
            clipboard_auto_paste = "auto";
            clipboard_confirm_clear_history = true;
            clipboard_enabled = true;
            clipboard_history_max_entries = 100;
            clipboard_image_action_command = "";
            clipboard_keep_from_closed_apps = true;
            corner_radius_scale = 0.0;
            date_format = "%A, %x";
            disable_mipmaps = false;
            external_ip_enabled = false;
            font_family = "Maple Mono Light";
            input_borders = true;
            launch_apps_as_systemd_services = false;
            launch_apps_custom_command = "";
            niri_overview_type_to_launch_enabled = false;
            offline_mode = false;
            password_style = "default";
            polkit_agent = false;
            popup_borders = true;
            popup_shadows = true;
            screen_time_enabled = false;
            settings_show_advanced = true;
            settings_window_translucent = false;
            setup_wizard_enabled = true;
            shared_gl_context = true;
            show_location = true;
            telemetry_enabled = false;
            time_format = "{:%H:%M}";
            animation = {
              enabled = true;
              speed = 1.0;
            };
            greeter_sync = {
              auto_sync = false;
            };
            keyboard_layout = {
            };
            launcher = {
              app_grid = false;
              auto_paste = "auto";
              categories = true;
              compact = true;
              fetch_exchange_rates = true;
              pinned = [];
              provider_prefix = "/";
              show_app_actions = false;
              show_icons = true;
              sort_by_usage = true;
              dmenu = {
              };
            };
            mpris = {
              blacklist = [];
            };
            panel = {
              borders = true;
              clipboard_placement = "attached";
              clipboard_position = "center";
              control_center_placement = "attached";
              control_center_position = "auto";
              floating_layer = "top";
              floating_offset = 8;
              launcher_placement = "attached";
              launcher_position = "center";
              list_item_background = false;
              open_near_click_clipboard = false;
              open_near_click_control_center = false;
              open_near_click_launcher = false;
              open_near_click_session = false;
              open_near_click_wallpaper = false;
              polkit_placement = "floating";
              polkit_position = "center";
              session_placement = "attached";
              session_position = "auto";
              shadow = false;
              transparency_mode = "glass";
              wallpaper_placement = "attached";
              wallpaper_position = "auto";
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
              filename_pattern = "";
              freeze_screen = true;
              pipe_command = "";
              pipe_to_command = false;
              remember_last_region = false;
              save_to_file = true;
              show_cursor = false;
            };
            session = {
              grid = false;
              grid_columns = 3;
              show_shortcuts = true;
              power = {
              };
              actions = [
                {
                  action = "lock";
                  command = "";
                  countdown_seconds = 0.0;
                  enabled = true;
                  glyph = "";
                  label = "";
                  shortcut = "1";
                  variant = "default";
                }
                {
                  action = "logout";
                  command = "";
                  countdown_seconds = 0.0;
                  enabled = true;
                  glyph = "";
                  label = "";
                  shortcut = "2";
                  variant = "default";
                }
                {
                  action = "lock_and_suspend";
                  command = "";
                  countdown_seconds = 0.0;
                  enabled = true;
                  glyph = "";
                  label = "";
                  shortcut = "3";
                  variant = "default";
                }
                {
                  action = "reboot";
                  command = "";
                  countdown_seconds = 0.0;
                  enabled = true;
                  glyph = "";
                  label = "";
                  shortcut = "4";
                  variant = "default";
                }
                {
                  action = "shutdown";
                  command = "";
                  countdown_seconds = 0.0;
                  enabled = true;
                  glyph = "";
                  label = "";
                  shortcut = "5";
                  variant = "destructive";
                }
              ];
            };
            shadow = {
              alpha = 0.550000011920929;
              direction = "center";
            };
          };
          storage = {
            key_file = "";
            key_source = "secret-service";
          };
          system = {
            monitor = {
              cpu_freq_activity_threshold = 2.5;
              cpu_freq_critical_threshold = 4.5;
              cpu_poll_seconds = 1.0;
              cpu_temp_activity_threshold = 60.0;
              cpu_temp_critical_threshold = 85.0;
              cpu_temp_sensor_path = "";
              cpu_usage_activity_threshold = 50.0;
              cpu_usage_critical_threshold = 90.0;
              disk_free_activity_threshold = 80.0;
              disk_free_critical_threshold = 95.0;
              disk_free_pct_activity_threshold = 80.0;
              disk_free_pct_critical_threshold = 95.0;
              disk_poll_seconds = 10.0;
              disk_used_activity_threshold = 80.0;
              disk_used_critical_threshold = 95.0;
              disk_used_pct_activity_threshold = 80.0;
              disk_used_pct_critical_threshold = 95.0;
              enabled = true;
              gpu_poll_seconds = 1.0;
              gpu_temp_activity_threshold = 60.0;
              gpu_temp_critical_threshold = 85.0;
              gpu_usage_activity_threshold = 50.0;
              gpu_usage_critical_threshold = 95.0;
              gpu_vram_activity_threshold = 50.0;
              gpu_vram_critical_threshold = 90.0;
              memory_poll_seconds = 1.0;
              net_rx_activity_threshold = 1.0;
              net_rx_critical_threshold = 50.0;
              net_tx_activity_threshold = 1.0;
              net_tx_critical_threshold = 50.0;
              network_poll_seconds = 1.0;
              ram_pct_activity_threshold = 60.0;
              ram_pct_critical_threshold = 90.0;
              swap_pct_activity_threshold = 20.0;
              swap_pct_critical_threshold = 80.0;
            };
          };
          theme = {
            builtin = "Kanagawa";
            community_palette = "Everforest";
            custom_palette = "";
            mode = "dark";
            pure_black_dark = false;
            source = "community";
            wallpaper_scheme = "m3-content";
            templates = {
              builtin_ids = [];
              community_ids = [];
              enable_builtin_templates = true;
              enable_community_templates = true;
            };
          };
          wallpaper = {
            directory = "${inputs.self}/assets/wallpapers";
            directory_dark = "";
            directory_light = "";
            edge_smoothness = 0.30000001192092896;
            enabled = true;
            fill_color = "";
            fill_mode = "crop";
            per_monitor_directories = false;
            transition = ["fade" "wipe" "disc" "stripes" "zoom" "honeycomb"];
            transition_duration = 1500.0;
            transition_on_startup = false;
            automation = {
              enabled = false;
              interval_seconds = 1800;
              order = "random";
              recursive = true;
            };
          };
          weather = {
            effects = true;
            enabled = true;
            refresh_minutes = 10;
            unit = "metric";
          };
          widget = {
            active_window = {
              icon_size = 14.0;
              max_length = 260.0;
              min_length = 80.0;
              title_scroll = "none";
              type = "active_window";
            };
            audio_visualizer = {
              bands = 32;
              centered = false;
              mirrored = false;
              show_when_idle = true;
              type = "audio_visualizer";
              width = 64;
            };
            bar = {
              show_bar_value = false;
              type = "yuuto/calculator:bar";
            };
            battery = {
              show_label = false;
              type = "battery";
            };
            brightness = {
              show_label = false;
              type = "brightness";
            };
            cat = {
              type = "noctalia/bongocat:cat";
            };
            control-center = {
              glyph = "brand-powershell";
              scale = 1.2;
              type = "control-center";
            };
            cpu = {
              glyph = "memory";
              show_value = false;
              stat = "cpu_usage";
              type = "sysmon";
              visualization = "none";
            };
            date = {
              format = "{:%a %d %b}";
              type = "clock";
            };
            input_volume = {
              device = "input";
              type = "volume";
            };
            keyboard_layout = {
              hide_when_single_layout = false;
              type = "keyboard_layout";
            };
            lock_keys = {
              display = "short";
              hide_when_off = false;
              show_caps_lock = true;
              show_num_lock = true;
              show_scroll_lock = false;
              type = "lock_keys";
            };
            media = {
              album_art_only = true;
              art_size = 16.0;
              max_length = 220.0;
              min_length = 80.0;
              title_scroll = "none";
              type = "media";
            };
            network = {
              show_label = false;
              type = "network";
              vpn_status = "both";
            };
            network_rx = {
              stat = "net_rx";
              type = "sysmon";
            };
            network_tx = {
              stat = "net_tx";
              type = "sysmon";
            };
            output_volume = {
              device = "output";
              type = "volume";
            };
            ram = {
              stat = "ram_used";
              type = "sysmon";
            };
            recorder = {
              type = "noctalia/screen_recorder:recorder";
            };
            spacer = {
              interactive = false;
              type = "spacer";
            };
            spacer_1 = {
              length = 16;
              type = "spacer";
            };
            spacer_2 = {
              length = 16;
              type = "spacer";
            };
            spacer_3 = {
              length = 16;
              type = "spacer";
            };
            spacer_4 = {
              length = 16;
              type = "spacer";
            };
            spacer_5 = {
              length = 24;
              type = "spacer";
            };
            spacer_6 = {
              length = 24;
              type = "spacer";
            };
            sysmon = {
              glyph = "vinyl";
              show_glyph = false;
              show_value = false;
              type = "sysmon";
              visualization = "graph";
            };
            temp = {
              stat = "cpu_temp";
              type = "sysmon";
            };
            tray = {
              capsule_opacity = 0.6;
              capsule_radius = 0;
              scale = 0.8;
              type = "tray";
            };
            volume = {
              show_label = false;
              type = "volume";
            };
            workspaces = {
              active_pill_size = 1.6;
              labels_only_when_occupied = true;
              type = "workspaces";
            };
          };
        };
      };
    };
  };
}
