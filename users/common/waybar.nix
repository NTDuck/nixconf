{ ... }:

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
          # Pango markup strictly enforces monospace at the rendering level
          format = "<span font_family='monospace'>VOL\n{volume:03d}%</span>";
          format-muted = "<span font_family='monospace'>MUT\n{volume:03d}%</span>";
          tooltip = false;
        };

        "backlight" = {
          format = "<span font_family='monospace'>LGT\n{percent:03d}%</span>";
          tooltip = false;
        };

        "network" = {
          format-wifi = "<span font_family='monospace'>WIF\n{signalStrength:03d}%</span>";
          format-ethernet = "<span font_family='monospace'>ETH\n100%</span>";
          format-disconnected = "<span font_family='monospace'>NET\nOFF</span>";
          tooltip = false;
        };

        "battery" = {
          states = {
            warning = 20;
            critical = 10;
          };
          format = "<span font_family='monospace'>BAT\n{capacity:03d}%</span>";
          format-charging = "<span font_family='monospace'>CHR\n{capacity:03d}%</span>";
          format-plugged = "<span font_family='monospace'>PLG\n{capacity:03d}%</span>";
          tooltip = false;
        };

        "cpu" = {
          format = "<span font_family='monospace'>CPU\n{usage:03d}%</span>";
          interval = 10;
          tooltip = false;
        };

        "memory" = {
          format = "<span font_family='monospace'>RAM\n{percentage:03d}%</span>";
          interval = 10;
          tooltip = false;
        };

        "clock" = {
          format = "<span font_family='monospace'>{:%d\n%m\n──\n%H\n%M}</span>";
          tooltip = false;
        };
      };
    };

    style = ''
      * {
        font-size: 10px;
        font-family: "JetBrainsMono Nerd Font", monospace;
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
        padding: 6px 2px;

        /* These bounds are now permanently locked because the text width cannot fluctuate */
        min-width: 40px;
        min-height: 36px;
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
