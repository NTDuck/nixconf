{ ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "left";
        width = 40;
        margin-top = 4;
        margin-bottom = 4;
        margin-left = 4;

        modules-left = [
          "custom/power"
          "custom/runner"
          "sway/workspaces"
        ];

        modules-center = [
          "sway/window"
        ];

        modules-right = [
          "group/stats"
          "clock"
        ];

        "clock" = {
          format = "{:%H\n%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        "custom/runner" = {
          format = "󰀻";
          on-click = "bemenu-run";
          tooltip = false;
        };

        "custom/power" = {
          format = "⏻";
          on-click = "poweroff";
          tooltip-format = "Power Off";
        };

        "sway/workspaces" = {
          disable-scroll = true;
          format = "{name}";
        };

        "sway/window" = {
          format = "{}";
          rotate = 270;
          rewrite = {
            "^null$" = "Desktop";
          };
        };

        "group/stats" = {
          modules = [
            "battery"
            "group/audio"
            "group/brightness"
          ];
          orientation = "inherit";
          drawer = {
            transition-duration = 500;
            transition-left-to-right = true;
          };
        };

        "group/audio" = {
          modules = [ "pulseaudio" "pulseaudio/slider" ];
          orientation = "inherit";
          drawer = {
            transition-duration = 500;
            transition-left-to-right = true;
          };
        };

        "pulseaudio" = {
          format = "{volume}\n{icon}";
          format-muted = "MUT\n󰝟";
          format-icons = {
            default = [ "" "" "" ];
          };
          on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          tooltip = false;
        };

        "pulseaudio/slider" = {
          min = 0;
          max = 100;
          orientation = "vertical";
        };

        "group/brightness" = {
          modules = [ "backlight" "backlight/slider" ];
          orientation = "inherit";
          drawer = {
            transition-duration = 500;
            transition-left-to-right = true;
          };
        };

        "backlight" = {
          format = "{percent}\n{icon}";
          format-icons = [ "" "" "" "" "" "" "" "" "" ];
          tooltip = false;
        };

        "backlight/slider" = {
          min = 3;
          max = 100;
          orientation = "vertical";
        };

        "battery" = {
          states = { warning = 30; critical = 15; };
          format = "{capacity}\n{icon}";
          format-charging = "{capacity}\n";
          format-plugged = "{capacity}\n";
          format-icons = [ "" "" "" "" "" ];
        };
      };
    };

    # The CSS style config for "Opaque Islands"
    style = ''
      * {
        font-size: 11px;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
      }

      /* Base Island styling */
      #custom-power,
      #custom-runner,
      #workspaces,
      #window,
      #group-stats,
      #clock {
        background: @base00;
        color: @base05;
        border-radius: 12px;
        margin-top: 5px;
        margin-bottom: 5px;
        padding: 10px 0px;
      }

      /* Hover States */
      #custom-power:hover,
      #custom-runner:hover,
      #clock:hover {
        background: @base02;
        color: @base0D;
        transition: 0.2s;
      }

      #workspaces button {
        padding: 6px 0px;
        color: @base04;
        background: transparent;
        border-radius: 0;
      }

      #workspaces button.focused {
        color: @base0D;
        background: rgba(0, 0, 0, 0.2);
        box-shadow: inset 2px 0px @base0D;
      }

      #workspaces button:hover {
        background: @base02;
      }

      /* Inner padding for stats drawer */
      #pulseaudio,
      #backlight,
      #battery {
        padding: 10px 0px;
      }

      #pulseaudio:hover,
      #backlight:hover,
      #battery:hover {
        color: @base0D;
      }

      /* Vertical Sliders */
      #pulseaudio-slider trough,
      #backlight-slider trough {
        min-height: 60px;
        min-width: 6px;
        border-radius: 4px;
        background: @base02;
        margin: 5px 0px;
      }

      #pulseaudio-slider highlight,
      #backlight-slider highlight {
        border-radius: 4px;
        background: @base05;
      }

      #pulseaudio-slider:hover highlight,
      #backlight-slider:hover highlight {
        background: @base0D;
      }
    '';
  };
}