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
        right = 0;
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
          format = "LGT\n{percentage}%";
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
        /* Force right alignment for both single and multi-line text */
        text-align: right;
        justify: right; 
      }

      /* --- ISOLATED ISLANDS FIX --- */
      /* Make the main window AND Ironbar's inner wrapper boxes completely transparent */
      window#ironbar,
      .background,
      .container {
        background: transparent;
        background-color: transparent;
        border: none;
        box-shadow: none;
      }

      /* Apply background and margins strictly to the individual modules */
      .volume, 
      .brightness, 
      .network_manager, 
      .sys_info, 
      .battery, 
      .clock {
        background: alpha(@base02, 0.80);
        color: @base05;
        border-radius: 4px;
        /* Vertical margins separate the modules into distinct islands */
        margin: 4px 0px; 
        padding: 8px 6px; 
      }

      .volume:hover, 
      .brightness:hover, 
      .network_manager:hover, 
      .sys_info:hover, 
      .battery:hover, 
      .clock:hover {
        background: alpha(@base03, 0.80);
        color: @base0D;
        transition: 0.2s;
      }

      /* --- NATIVE MODULE QUIRK FIXES --- */

      /* 1. Hide the microphone (source) to prevent the "2 VOL" horizontal split */
      .volume .source {
        display: none;
      }
      
      /* 2. Hide the native GTK sliders from volume and brightness to keep it text-only */
      .volume scale,
      .brightness scale {
        display: none;
      }

      /* --- WORKSPACES --- */
      .workspaces {
        background: transparent;
        margin: 0;
        padding: 0;
      }

      .workspaces .item {
        padding: 6px 6px;
        /* Enforce vertical spacing between workspace buttons to match the islands */
        margin: 0px 0px 4px 0px; 
        color: @base04;
        background: alpha(@base02, 0.80);
        border-radius: 4px;
        border: none;
        box-shadow: none;
      }

      .workspaces .item.focused {
        color: @base0D;
        background: alpha(@base03, 0.80);
        font-weight: 900;
      }

      .workspaces .item:hover {
        background: alpha(@base03, 0.80);
        color: @base05;
      }
    '';
  };
}