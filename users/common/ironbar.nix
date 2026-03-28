{ pkgs, ... }:

{
  programs.ironbar = {
    enable = true;
    
    features = [ "upower" "http" ]; # upower needed for battery

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
          # Sway/Hyprland workspaces
          sort = "alphanumeric";
        }
      ];

      end = [
        {
          type = "volume";
          format = "VOL\n{percentage}%";
          max_volume = 100;
          on_click_right = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        }
        {
          # Network module doesn't natively do multiline easily, so we use a custom script or simplified layout
          type = "network";
          format = "NET\n{icon}";
        }
        {
          type = "upower";
          format = "BAT\n{percentage}%";
        }
        {
          type = "sys_info";
          format = [
            "CPU\n{cpu_percent}%"
            "RAM\n{memory_percent}%"
          ];
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
        font-family: "JetBrainsMono Nerd Font";
        font-size: 10px;
      }

      window#ironbar {
        background: rgba(24, 24, 24, 0.85); /* Adjust to your @base00 */
        border-radius: 4px;
      }

      .widget {
        background: rgba(40, 40, 40, 0.85); /* Adjust to @base02 */
        color: #d8d8d8; /* Adjust to @base05 */
        border-radius: 2px;
        margin: 4px;
        padding: 6px 0px;
      }

      .widget:hover {
        background: rgba(56, 56, 56, 0.85); /* @base03 */
        color: #8ab4f8; /* @base0D */
        transition: 0.2s;
      }
      
      /* Workspaces styling */
      .workspaces .item {
        padding: 4px 0px;
        margin-bottom: 4px;
        color: #b8b8b8;
        background: rgba(40, 40, 40, 0.85);
        border-radius: 2px;
      }

      .workspaces .item.focused {
        color: #8ab4f8;
        background: rgba(56, 56, 56, 0.85);
        font-weight: 900;
      }
    '';
  };
}