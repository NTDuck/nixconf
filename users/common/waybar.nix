{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "left";

        # The margins for the main background bar itself
        margin-top = 4;
        margin-bottom = 4;
        margin-left = 4;
        margin-right = 4;

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
          format = "{name}"; 
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
          format = "CLK\n{:%H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
      };
    };

    style = ''
      * {
        font-size: 11px;
        min-height: 0;
      }

      /* The main bar behind the islands */
      window#waybar {
        background: @base00;
        border-radius: 4px; /* Slightly round the main bar's outer corners */
      }

      /* The isolated islands */
      #pulseaudio,
      #backlight,
      #network,
      #cpu,
      #memory,
      #battery,
      #clock {
        background: @base02;
        color: @base05;
        border-radius: 2px; /* 2px rounded corners as requested */
        margin: 4px; /* Creates the gap between the islands and the outer bar */
        padding: 6px 0px; /* Vertical padding to space the stacked text */
        min-width: 40px; /* Gives enough width for 000% to fit */
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
        background: @base03;
        color: @base0D;
        transition: 0.2s;
      }

      window#waybar #workspaces button {
        padding: 4px 0px;
        margin-bottom: 4px;
        color: @base04;
        background: @base02;
        border-radius: 2px;
        
        border: none;
        border-bottom: 2px solid transparent;
        box-shadow: none;
      }

      window#waybar #workspaces button.focused {
        color: @base0D;
        background: @base03;

        border: none;
        border-bottom: 2px solid transparent;
        
        box-shadow: none;
        text-shadow: none;
        text-decoration: none;
        font-weight: 900;
      }

      window#waybar #workspaces button:hover {
        background: @base03;
        color: @base05;
        border-bottom: 2px solid transparent;
      }
    '';
  };
}