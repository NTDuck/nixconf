{ pkgs, inputs, ... }:

{
  imports = [
    inputs.ironbar.homeManagerModules.default
  ];

  programs.ironbar = {
    enable = true;

    config = {
      position = "left";
      margin = {
        top = 4;
        bottom = 4;
        left = 4;
      };

      start = [
        {
          type = "workspaces";
          sort = "index";
        }
      ];

      end = [
        {
          # Replaces native volume module to stop mic/speaker duplication
          type = "script";
          mode = "poll";
          interval = 1000;
          name = "volume-script";
          # Fetch the 5th space-separated word from pactl (e.g., '100%')
          cmd = ''
            vol=$(${pkgs.pulseaudio}/bin/pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')
            echo -e "VOL\n$vol"
          '';
          on_scroll_down = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
          on_scroll_up = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
          on_click_left = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        }
        {
          # Replaces native brightness module to strip the forced icon
          type = "script";
          mode = "poll";
          interval = 1000;
          name = "brightness-script";
          # Fetch the 4th comma-separated word from brightnessctl (e.g., '100%')
          cmd = ''
            b=$(${pkgs.brightnessctl}/bin/brightnessctl -m | awk -F, '{print $4}')
            echo -e "LGT\n$b"
          '';
          on_scroll_down = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
          on_scroll_up = "${pkgs.brightnessctl}/bin/brightnessctl set +5%";
        }
        {
          type = "network_manager";
        }
        {
          type = "battery";
          format = "BAT\n{percentage}%";
        }
        {
          type = "sys_info";
          format = [ "CPU\n{cpu_percent}%\nRAM\n{memory_percent}%\nTMP\n{temp_c}°C\nSTO\n{disk_percent}%" ];
          interval = 10;
        }
        {
          type = "clock";
          format = "%d\n%m\n──\n%H\n%M";
        }
      ];
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Inter", sans-serif;
        font-size: 10px;
        min-height: 0;
      }

      /* * ISOLATED ISLANDS: 
       * Setting the main bar window to transparent removes the connected pillar look.
       */
      window#ironbar {
        background: transparent;
        background-color: transparent;
        border: none;
        box-shadow: none;
      }

      /* * MODULE STYLING 
       * Referencing the custom scripts via #id 
       */
      #volume-script, 
      #brightness-script, 
      .network_manager, 
      .sys_info, 
      .battery, 
      .clock {
        background: alpha(@base02, 0.80);
        color: @base05;
        border-radius: 2px;
        margin: 4px;
        padding: 6px 0px;
      }

      #volume-script:hover, 
      #brightness-script:hover, 
      .network_manager:hover, 
      .sys_info:hover, 
      .battery:hover, 
      .clock:hover {
        background: alpha(@base03, 0.80);
        color: @base0D;
        transition: 0.2s;
      }

      /* WORKSPACES */
      .workspaces {
        background: transparent;
        margin: 4px;
      }

      .workspaces .item {
        padding: 4px 0px;
        /* Force GTK to remove internal margins between blocks to fix them being too far apart */
        margin: 0px 0px 4px 0px; 
        min-height: 0;
        min-width: 0;

        color: @base04;
        background: alpha(@base02, 0.80);
        border-radius: 2px;
        border: none;
        border-bottom: 2px solid transparent;
        box-shadow: none;
      }

      .workspaces .item.focused {
        color: @base0D;
        background: alpha(@base03, 0.80);
        border: none;
        border-bottom: 2px solid transparent;
        box-shadow: none;
        text-shadow: none;
        text-decoration: none;
        font-weight: 900;
      }

      .workspaces .item:hover {
        background: alpha(@base03, 0.80);
        color: @base05;
        border-bottom: 2px solid transparent;
      }
    '';
  };
}