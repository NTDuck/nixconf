{ pkgs, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.sway;

    systemd.enable = true;
    xwayland = true;

    wrapperFeatures.gtk = true;

    config = rec {
      modifier = "Mod4";

      terminal = "${pkgs.unstable.foot}/bin/footclient";
      menu = "${pkgs.unstable.tofi}/bin/tofi-drun --drun-launch=true";

      bars = [
        { command = "${pkgs.unstable.waybar}/bin/waybar"; }
      ];

      startup = [
        {
          # command = "${pkgs.fcitx5}/bin/fcitx5 -d -r";
          command = "fcitx5 -d -r";
          always = true;
        }
        {
          command = "${pkgs.unstable.autotiling-rs}/bin/autotiling-rs";
          always = true;
        }
      ];

      keybindings = {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+d" = "exec ${menu}";
        "${modifier}+Ctrl+l" = "exec ${pkgs.unstable.gtklock}/bin/gtklock";

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
        "${modifier}+Shift+E" = "exit";

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
        "type:keyboard" = {
          repeat_delay = "200";
          repeat_rate = "50";
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

  services.swayidle = {
    enable = true;
    package = pkgs.swayidle;

    events = [
      {
        event = "before-sleep";
        command = "${pkgs.unstable.gtklock}/bin/gtklock";
      }
      {
        event = "after-resume";
        command = "swaymsg 'output * dpms on'";
      }
    ];
    # timeouts = [
    #   {
    #     timeout = 600;
    #     command = "swaymsg 'output * dpms off'";
    #   }
    # ];
  };
}
