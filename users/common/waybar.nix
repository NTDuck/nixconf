{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "left";

        margin-top = 2;
        margin-bottom = 2;
        margin-left = 2;

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
          format = "{icon}{name} ";
          format-icons = {
            focused = "*";
            default = " ";
          };
        };

        "pulseaudio" = {
          format = "{icon} {volume:02d}%";
          format-muted = "󰝟 {volume:02d}%";
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
          format = "{icon} {percent:02d}%";
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
            warning = 20;
            critical = 10;
          };
          format = "{icon} {capacity:02d}%";
          format-charging = " {capacity:02d}%";
          format-plugged = " {capacity:02d}%";
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
          format = " {usage:02d}%";
          interval = 10;
          tooltip = false;
        };

        "memory" = {
          format = " {percentage:02d}%";
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
        padding: 8px 4px;
      }

      #workspaces {
        background: transparent;
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

      #workspaces button {
        padding: 2px 4px;
        margin-bottom: 4px;
        color: @base04;
        background: @base00;
        border-radius: 8px;
        box-shadow: none;
        border: none;
        border-bottom: none;
      }

      #workspaces button.focused {
        color: @base0D;
        background: @base02;

        box-shadow: none;
        text-shadow: none;

        border: none;
        border-bottom: none;
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
