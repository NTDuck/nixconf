{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "left";
        width = 26;
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
          format = "{volume}%{icon}";
          format-muted = "{volume}%󰝟";
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
          format = "{percent}%{icon}";
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
          format = "{capacity}%\n{icon}";
          format-charging = "{capacity}%\n";
          format-plugged = "{capacity}%\n";
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
          format = "{usage}%";
          interval = 10;
          tooltip = false;
        };

        "memory" = {
          format = "{percentage}%";
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

      #workspaces,
      #pulseaudio,
      #backlight,
      #network,
      #cpu,
      #memory,
      #battery,
      #clock {
        background: @base00;
        color: @base05;
        border-radius: 50%;
        margin-top: 4px;
        margin-bottom: 4px;
        padding: 8px 0px;
      }

      #workspaces:hover,
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
        padding: 4px 0px;
        color: @base04;
        background: transparent;
        border-radius: 0;
        box-shadow: none;
      }

      #workspaces button.focused {
        color: @base0D;
        background: transparent;
        box-shadow: none;
        font-weight: 900;
      }

      #workspaces button:hover {
        background: transparent;
        color: @base05;
      }

      #pulseaudio,
      #backlight,
      #network,
      #cpu,
      #memory,
      #battery {
        padding: 8px 0px;
      }

      #pulseaudio:hover,
      #backlight:hover,
      #network:hover,
      #cpu:hover,
      #memory:hover,
      #battery:hover {
        color: @base0D;
      }
    '';
  };
}
