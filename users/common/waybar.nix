{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "left";
        # Removed "width = 26;" so the bar automatically scales to fit your content
        margin-top = 4;
        margin-bottom = 4;
        margin-left = 4;

        modules-left = [
          "sway/workspaces"
        ];
        modules-center = [ ];

        modules-right = [
          "pulseaudio"
          "backlight"
          "network"
          "battery"
          "cpu"
          "memory"
          "clock"
        ];

        "sway/workspaces" = {
          disable-scroll = true;
          format = "{icon}{name}";
          format-icons = {
            focused = "*";
            default = "";
          };
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 {volume}%";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          tooltip = false;
        };

        "backlight" = {
          format = "{icon} {percent}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
          tooltip = false;
        };

        "network" = {
          format-wifi = "󰤨";
          format-ethernet = "󰈀";
          format-disconnected = "󰤭";
          tooltip-format = "{ifname} via {gwaddr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{ipaddr}/{cidr}";
          tooltip-format-disconnected = "Disconnected";
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          tooltip-format = "{power} W, {timeTo}";
        };

        "cpu" = {
          format = " {usage}%";
          interval = 10;
          tooltip = false;
        };

        "memory" = {
          format = " {percentage}%";
          interval = 10;
          tooltip = false;
        };

        "clock" = {
          format = "{:%H\n%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
      };
    };

    style = ''
      * {
        font-size: 11px;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
      }

      #pulseaudio,
      #backlight,
      #network,
      #cpu,
      #memory,
      #battery,
      #clock {
        background: @base00;
        color: @base05;
        border-radius: 8px;
        margin-top: 4px;
        margin-bottom: 4px;
        padding: 8px 4px; /* Added slight horizontal padding for newly widened items */
      }

      #workspaces {
        background: transparent; /* Removed background so workspaces are isolated */
        margin-top: 4px;
        margin-bottom: 4px;
      }

      #pulseaudio:hover,
      #backlight:hover,
      #network:hover,
      #cpu:hover,
      #memory:hover,
      #battery:hover,
      #clock:hover {
        background: @base02;
        color: @base0D;
        transition: 0.2s;
      }

      /* Workspace isolated islands */
      #workspaces button {
        padding: 2px 4px; /* Shrunk padding from 4 to 2 */
        margin-bottom: 4px; /* Creates the gap between islands */
        color: @base04;
        background: @base00; /* Island background color */
        border-radius: 8px; /* Rounding for the individual islands */
        box-shadow: none;
        border: none;
        border-bottom: none; /* Emphasize no underline */
      }

      #workspaces button.focused {
        color: @base0D;
        background: @base02;
        box-shadow: none;
        border: none;
        border-bottom: none; /* Prevents waybar's default white bottom border */
        text-decoration: none;
        font-weight: 900;
      }

      #workspaces button:hover {
        background: @base02;
        color: @base05;
      }
    '';
  };
}
