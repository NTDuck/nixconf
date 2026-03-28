{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "left";

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
          format = "{icon}{name} ";
          format-icons = {
            focused = "*";
            default = " ";
          };
        };

        "pulseaudio" = {
          format = "VOL\n{volume:03d}%";
          format-muted = "MUT\n{volume:03d}%";
          on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          tooltip = false;
        };

        "backlight" = {
          format = "LGT\n{percent:03d}%";
          tooltip = false;
        };

        "network" = {
          format-wifi = "WIF\n{signalStrength:03d}%";
          format-ethernet = "ETH\n100%";
          format-disconnected = "NET\nOFF";
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
          format = "BAT\n{capacity:03d}%";
          format-charging = "CHR\n{capacity:03d}%";
          format-plugged = "PLG\n{capacity:03d}%";
          tooltip-format = "{power} W, {timeTo}";
        };

        "cpu" = {
          format = "CPU\n{usage:03d}%";
          interval = 10;
          tooltip = false;
        };

        "memory" = {
          format = "RAM\n{percentage:03d}%";
          interval = 10;
          tooltip = false;
        };

        "clock" = {
          format = "{:%d\n%m\n──\n%H\n%M}";
          # tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          tooltip = false;
        };
      };
    };

    style = ''
      * {
        font-size: 10px;
        font-family: monospace;
        min-height: 0;
      }

      window#waybar {
        background: alpha(@base00, 0.85);
        border-radius: 4px;
      }

      #pulseaudio,
      #backlight,
      #network,
      #cpu,
      #memory,
      #battery,
      #clock {
        background: alpha(@base02, 0.85);
        color: @base05;
        border-radius: 2px;
        margin: 4px;
        padding: 6px 0px;
        /* min-width: 40px; */
      }

      #workspaces {
        background: transparent;
        margin: 4px;
      }

      #pulseaudio:hover,
      #backlight:hover,
      #network:hover,
      #cpu:hover,
      #memory:hover,
      #battery:hover,
      #clock:hover {
        background: alpha(@base03, 0.85);
        color: @base0D;
        transition: 0.2s;
      }

      window#waybar #workspaces button {
        padding: 4px 0px;
        margin-bottom: 4px;
        color: @base04;
        background: alpha(@base02, 0.85);
        border-radius: 2px;

        border: none;
        border-bottom: 2px solid transparent;
        box-shadow: none;
      }

      window#waybar #workspaces button.focused {
        color: @base0D;
        background: alpha(@base03, 0.85);

        border: none;
        border-bottom: 2px solid transparent;

        box-shadow: none;
        text-shadow: none;
        text-decoration: none;
        font-weight: 900;
      }

      window#waybar #workspaces button:hover {
        background: alpha(@base03, 0.85);
        color: @base05;
        border-bottom: 2px solid transparent;
      }
    '';
  };
}
