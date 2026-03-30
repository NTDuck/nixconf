{ pkgs, inputs, ... }:

{
  imports = [
    inputs.ironbar.homeManagerModules.default
  ];

  programs.ironbar = {
    enable = true;

    config = {
      position = "left";

      height = 32;
      margin = {
        top = 4;
        bottom = 4;
        left = 4;
      };

      start = [
        {
          type = "workspaces";
        }
      ];

      end = [
        {
          type = "volume";
          format = "VOL\n{percentage:03}%";
          max_volume = 100;
          on_click_right = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        }
        {
          type = "script";
          mode = "poll";
          interval = 1000;
          cmd = "echo \"LGT\n$(${pkgs.brightnessctl}/bin/brightnessctl -m | ${pkgs.gawk}/bin/awk -F, '{print $4}')\"";
        }
        {
          # Corrected module name
          type = "network_manager";
        }
        {
          type = "battery";
          format = "BAT\n{percentage}%";
        }
        {
          type = "sys_info";
          format = [ "CPU\n{cpu_percent:03}%" ];
          interval = 10;
        }
        {
          type = "sys_info";
          format = [ "RAM\n{memory_percent:03}%" ];
          interval = 10;
        }
        {
          type = "clock";
          format = "%d\n%m\n \n%H\n%M";
        }
      ];
    };

    style = ''
      * {
        font-size: 10px;
      }

      window#ironbar {
        background: alpha(@base00, 0.85);
        border-radius: 4px;
      }

      /* Updated selectors: .network -> .network_manager and .upower -> .battery */
      .volume, .script, .network_manager, .sys_info, .battery, .clock {
        background: alpha(@base02, 0.85);
        color: @base05;
        border-radius: 2px;
        margin: 4px;
        padding: 6px 0px;
      }

      .volume:hover, .script:hover, .network_manager:hover, .sys_info:hover, .battery:hover, .clock:hover {
        background: alpha(@base03, 0.85);
        color: @base0D;
        transition: 0.2s;
      }

      .workspaces {
        background: transparent;
        margin: 4px;
      }

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
