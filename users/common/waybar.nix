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

        # --- AUDIO ---
        "pulseaudio" = {
          format = "VOL \n{volume:03d}%";
          format-muted = "MUT \n{volume:03d}%";
          tooltip = false;
        };

        # --- BACKLIGHT ---
        "backlight" = {
          format = "LGT \n{percent:03d}%";
          tooltip = false;
        };

        # --- NETWORK ---
        "network" = {
          format-wifi = "WIF \n{signalStrength:03d}%";
          format-ethernet = "ETH \n100%";
          format-disconnected = "NET \nOFF ";
          tooltip = false;
        };

        # --- BATTERY ---
        "battery" = {
          states = {
            warning = 20;
            critical = 10;
          };
          format = "BAT \n{capacity:03d}%";
          format-charging = "CHR \n{capacity:03d}%";
          format-plugged = "PLG \n{capacity:03d}%";
          tooltip = false;
        };

        # --- CPU ---
        "cpu" = {
          format = "CPU \n{usage:03d}%";
          interval = 10;
          tooltip = false;
        };

        # --- MEMORY ---
        "memory" = {
          format = "RAM \n{percentage:03d}%";
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

      window#waybar {
        background: alpha(@base00, 0.85);
        border-radius: 4px;
      }

      /* Apply the island background directly to the individual modules */
      #pulseaudio,
      #backlight,
      #network,
      #battery,
      #cpu,
      #memory,
      #clock {
        background: alpha(@base02, 0.85);
        color: @base05;
        border-radius: 2px;
        margin: 4px;
        padding: 6px 4px;
      }

      #workspaces {
        background: transparent;
        margin: 4px;
      }

      /* Hover states target the individual modules */
      #pulseaudio:hover,
      #backlight:hover,
      #network:hover,
      #battery:hover,
      #cpu:hover,
      #memory:hover,
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
