{ lib, pkgs, ... }:

{
  wayland.windowManager.sway = {
    enable = true;

    systemd.enable = true;
    xwayland = true;

    wrapperFeatures.gtk = true;

    config = rec {
      modifier = "Mod4";

      # terminal = "${pkgs.foot}/bin/footclient";
      # menu = "${pkgs.bemenu}/bin/bemenu-run";
      terminal = "footclient";
      menu = "bemenu-run";

      bars = [
        { command = "${pkgs.waybar}/bin/waybar"; }
      ];

      startup = [
        {
          command = "sleep 8 && ${pkgs.fcitx5}/bin/fcitx5 -d -r";
          always = true;
        }
        {
          command = "${pkgs.autotiling-rs}/bin/autotiling-rs";
          always = true;
        }
        {
          command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP";
          always = true;
        }
      ];

      keybindings = {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+d" = "exec ${menu}";

        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";

        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";

        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";

        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";

        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+e" = "layout toggle split";

        "${modifier}+q" = "kill";

        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";

        "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
      };

      input = {
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
          dwt = "enabled";
        };
      };

      gaps = {
        inner = 4;
        outer = 0;
        # smartGaps = true;
      };

      window = {
        titlebar = false;
        border = 2;
      };
    };
  };

programs.waybar = {
    enable = true;
    
    settings = {
      mainBar = {
        layer = "top";
        position = "top";

        modules-left = [ "custom/space" "battery" "sway/workspaces" ];
        modules-center = [ "custom/space" "cpu" "custom/runner" "memory" ];
        modules-right = [ "pulseaudio" "sway/language" "clock" "custom/space" ];

        "custom/space" = {
          format = " ";
          tooltip = false;
        };

        "custom/runner" = {
          format = "";
          on-click = "bemenu-run"; # Adapted from wofi
        };

        "sway/workspaces" = {
          disable-scroll = true;
          format = "{name}";
        };

        "clock" = {
          format = "{:%B %d %I:%M %p} |  ";
        };

        "pulseaudio" = {
          format = "{icon} {volume:2}%";
          format-bluetooth = "{icon}  {volume}%";
          format-muted = "{icon} MUTE";
          format-icons = {
            headphones = "";
            default = [ "" "" ];
          };
          scroll-step = 5;
          # on-click = "pamixer -t";
          # on-click-right = "pavucontrol";
        };

        "sway/language" = {
          format = "  {short}";
          on-click = "swaymsg input type:keyboard xkb_switch_layout next";
        };

        "memory" = {
          interval = 1;
          format = "  {}%";
          on-click = "footclient -e btop"; # Adapted from gnome-system-monitor
        };

        "cpu" = {
          interval = 1;
          format = " {usage:2}%";
          on-click = "footclient -e btop"; # Adapted from gnome-system-monitor
        };

        "battery" = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon}  | {capacity}%";
          format-icons = [ "" "" "" "" "" ];
        };
      };
    };

    # The CSS style config 
    style = ''
      * {
        font-size: 18px;
        /* Stylix automatically handles the font-family */
      }

      window#waybar {
        background: transparent;
      }

      /* Using Stylix dynamic base colors instead of hardcoded hex codes */
      #workspaces,
      #clock,
      #pulseaudio,
      #memory,
      #cpu,
      #battery,
      #network,
      #language,
      #custom-runner {
        background: @base00;
        color: @base05;
        border-radius: 15px;
        margin-top: 7px;
        margin-left: 7px;
        margin-right: 7px;
        padding: 3px 10px;
      }

      #custom-runner {
        padding-left: 10px;
        padding-right: 12px;
      }

      #workspaces button {
        padding: 0 5px;
        color: @base04;
      }

      #workspaces button.focused {
        color: @base0D; /* Stylix accent color */
      }

      #workspaces button:hover,
      #pulseaudio:hover,
      #cpu:hover,
      #memory:hover,
      #battery:hover,
      #clock:hover,
      #language:hover {
        background: @base02; /* Stylix hover color */
      }
    '';
  };

  home.packages = [
    pkgs.btop
  ];
}
