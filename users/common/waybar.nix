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
        margin-top: 2px;
        margin-bottom: 2px;
        padding: 4px 2px;
        min-width: 20px;
      }

      #workspaces {
        background: transparent;
        margin-top: 2px;
        margin-bottom: 2px;
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

      window#waybar #workspaces button {
        padding: 1px 2px;
        margin-bottom: 2px;
        color: @base04;
        background: @base00;
        border-radius: 4px;
        
        border: none;
        border-bottom: 2px solid transparent;
        box-shadow: none;
      }

      window#waybar #workspaces button.focused {
        color: @base0D;
        background: @base02;

        border: none;
        border-bottom: 2px solid transparent;
        
        box-shadow: none;
        text-shadow: none;
        text-decoration: none;
        font-weight: 900;
      }

      window#waybar #workspaces button:hover {
        background: @base02;
        color: @base05;
        border-bottom: 2px solid transparent;
      }
    '';
  };
}
