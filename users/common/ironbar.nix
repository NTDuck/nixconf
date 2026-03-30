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
          sort = "index";
        }
      ];

      end = [
        {
          type = "volume";
          format = "VOL\n{percentage}%";
        }
        {
          type = "brightness";
          format = "LGT\n{percentage}$";
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
          format = "%d\n%m\n__\n%H\n%M";
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
