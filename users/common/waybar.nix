{ ... }:

{
  programs.ironbar = {
    enable = true;

    config = {
      position = "left";
      margin = {
        top = 4;
        bottom = 4;
        left = 4;
        right = 0;
      };

      start = [
        { type = "workspaces"; }
      ];

      center = [ ];

      end = [
        # --- AUDIO ---
        {
          type = "volume";
          # Ironbar's volume widget natively handles the slider and icons.
          # Advanced format overrides may require a custom script depending on your Ironbar version.
        }

        # --- BACKLIGHT ---
        {
          type = "brightness";
        }

        # --- NETWORK (Custom Script Fallback) ---
        {
          name = "network";
          type = "script";
          mode = "poll";
          interval = 5;
          # Mimics your Waybar WIF/ETH/OFF padding logic exactly
          cmd = ''
            if grep -q 'up' /sys/class/net/wl*/operstate 2>/dev/null; then
              echo "WIF \n100%"
            elif grep -q 'up' /sys/class/net/e*/operstate 2>/dev/null; then
              echo "ETH \n100%"
            else
              echo "NET \nOFF "
            fi
          '';
        }

        # --- BATTERY ---
        {
          type = "battery";
        }

        # --- CPU ---
        {
          name = "cpu";
          type = "sys_info";
          interval = 10;
          # Ironbar uses Rust formatting. :03 ensures 3 digits, padded with zeros.
          format = [ "CPU \n{cpu_percent:03}%" ];
        }

        # --- MEMORY ---
        {
          name = "memory";
          type = "sys_info";
          interval = 10;
          format = [ "RAM \n{memory_percent:03}%" ];
        }

        # --- CLOCK ---
        {
          type = "clock";
          format = "%d\n%m\n──\n%H\n%M";
        }
      ];
    };

    style = ''
      * {
        font-size: 10px;
        font-family: monospace;
        min-height: 0;
      }

      /* Base bar background */
      .background {
        background: alpha(@base00, 0.85);
        border-radius: 4px;
      }

      /* Apply the island background directly to the Ironbar classes */
      .volume,
      .brightness,
      #network,
      .battery,
      #cpu,
      #memory,
      .clock {
        background: alpha(@base02, 0.85);
        color: @base05;
        border-radius: 2px;
        margin: 4px;
        padding: 6px 4px;
      }

      .workspaces {
        background: transparent;
        margin: 4px;
      }

      /* Hover states target the individual modules */
      .volume:hover,
      .brightness:hover,
      #network:hover,
      .battery:hover,
      #cpu:hover,
      #memory:hover,
      .clock:hover {
        background: alpha(@base03, 0.85);
        color: @base0D;
        transition: 0.2s;
      }

      /* Ironbar uses '.item' instead of 'button' for workspaces */
      .workspaces .item {
        padding: 4px 0px;
        margin-bottom: 4px;
        color: @base04;
        background: alpha(@base02, 0.85);
        border-radius: 2px;

        border: none;
        border-bottom: 2px solid transparent;
        box-shadow: none;
      }

      .workspaces .item.focused {
        color: @base0D;
        background: alpha(@base03, 0.85);

        border: none;
        border-bottom: 2px solid transparent;

        box-shadow: none;
        text-shadow: none;
        text-decoration: none;
        font-weight: 900;
      }

      .workspaces .item:hover {
        background: alpha(@base03, 0.85);
        color: @base05;
        border-bottom: 2px solid transparent;
      }
    '';
  };
}
