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
          "group/audio"
          "group/light"
          "group/net"
          "group/bat"
          "group/cpu"
          "group/ram"
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

        # --- AUDIO ---
        "group/audio" = {
          orientation = "vertical";
          modules = [
            "pulseaudio#label"
            "pulseaudio#value"
          ];
        };
        "pulseaudio#label" = {
          format = "VOL";
          format-muted = "MUT";
          tooltip = false;
        };
        "pulseaudio#value" = {
          format = "{volume:03d}%";
          format-muted = "{volume:03d}%";
          tooltip = false;
        };

        # --- BACKLIGHT ---
        "group/light" = {
          orientation = "vertical";
          modules = [
            "backlight#label"
            "backlight#value"
          ];
        };
        "backlight#label" = {
          format = "LGT";
          tooltip = false;
        };
        "backlight#value" = {
          format = "{percent:03d}%";
          tooltip = false;
        };

        # --- NETWORK ---
        "group/net" = {
          orientation = "vertical";
          modules = [
            "network#label"
            "network#value"
          ];
        };
        "network#label" = {
          format-wifi = "WIF";
          format-ethernet = "ETH";
          format-disconnected = "NET";
          tooltip = false;
        };
        "network#value" = {
          format-wifi = "{signalStrength:03d}%";
          format-ethernet = "100%";
          format-disconnected = "OFF";
          tooltip = false;
        };

        # --- BATTERY ---
        "group/bat" = {
          orientation = "vertical";
          modules = [
            "battery#label"
            "battery#value"
          ];
        };
        "battery#label" = {
          states = {
            warning = 20;
            critical = 10;
          };
          format = "BAT";
          format-charging = "CHR";
          format-plugged = "PLG";
          tooltip = false;
        };
        "battery#value" = {
          states = {
            warning = 20;
            critical = 10;
          };
          format = "{capacity:03d}%";
          format-charging = "{capacity:03d}%";
          format-plugged = "{capacity:03d}%";
          tooltip = false;
        };

        # --- CPU ---
        "group/cpu" = {
          orientation = "vertical";
          modules = [
            "cpu#label"
            "cpu#value"
          ];
        };
        "cpu#label" = {
          format = "CPU";
          interval = 10;
          tooltip = false;
        };
        "cpu#value" = {
          format = "{usage:03d}%";
          interval = 10;
          tooltip = false;
        };

        # --- MEMORY ---
        "group/ram" = {
          orientation = "vertical";
          modules = [
            "memory#label"
            "memory#value"
          ];
        };
        "memory#label" = {
          format = "RAM";
          interval = 10;
          tooltip = false;
        };
        "memory#value" = {
          format = "{percentage:03d}%";
          interval = 10;
          tooltip = false;
        };

        # --- CLOCK ---
        "clock" = {
          format = "{:%d\n%m\n──\n%H\n%M}";
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

      /* Main background bar */
      window#waybar {
        background: alpha(@base00, 0.85);
        border-radius: 4px;
      }

      /* * ISOLATED ISLANDS
       */
      .group-audio,
      .group-light,
      .group-net,
      .group-bat,
      .group-cpu,
      .group-ram,
      #clock {
        background: alpha(@base02, 0.85);
        color: @base05;
        border-radius: 2px;
        margin: 4px;
        padding: 6px 2px;

        /* A minimal width that perfectly fits 4 characters.
           This locks the VOL/MUT width without bloating the bar! */
        min-width: 36px;
      }

      /* Hover states for the islands */
      .group-audio:hover,
      .group-light:hover,
      .group-net:hover,
      .group-bat:hover,
      .group-cpu:hover,
      .group-ram:hover,
      #clock:hover {
        background: alpha(@base03, 0.85);
        color: @base0D;
        transition: 0.2s;
      }

      /* Ensure the inner text lines don't have overlapping backgrounds */
      #pulseaudio,
      #backlight,
      #network,
      #cpu,
      #memory,
      #battery {
        background: transparent;
        margin: 0px;
        padding: 0px;
      }

      /* --- WORKSPACES --- */
      #workspaces {
        background: transparent;
        margin: 4px;
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
