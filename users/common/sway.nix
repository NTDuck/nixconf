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
        {
          position = "top";
          statusCommand = "${pkgs.yambar}/bin/yambar";
        }
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

  programs.yambar = {
    enable = true;
    settings = {
      bar = {
        height = 30;
        location = "top";

        left = [
          {
            i3 = {
              content = {
                "" = {
                  map = {
                    default = { string = { text = " {name} "; }; };
                    conditions = {
                      "state == focused" = { string = { text = " [{name}] "; }; };
                    };
                  };
                };
                "current" = {
                  string = { text = "  {title}"; };
                };
              };
            };
          }
        ];

        center = [
          {
            clock = {
              time_format = "%H:%M";
              content = [
                { string = { text = "{time}"; }; }
              ];
            };
          }
        ];

        right = [
          {
            alsa = {
              card = "default";
              content = [
                {
                  map = {
                    conditions = {
                      "muted" = { string = { text = " {percent}%   "; }; };
                      "~muted" = { string = { text = " {percent}%   "; }; };
                    };
                  };
                }
              ];
            };
          }
          {
            backlight = {
              name = "intel_backlight";
              content = [
                { string = { text = "Blt {percent}%   "; }; }
              ];
            };
          }
          {
            cpu = {
              content = [
                { string = { text = "CPU {cpu}%   "; }; }
              ];
            };
          }
          {
            mem = {
              content = [
                { string = { text = "RAM {used_percent}%   "; }; }
              ];
            };
          }
          {
            battery = {
              name = "BAT0";
              content = [
                {
                  map = {
                    default = { string = { text = "Bat {capacity}% "; }; };
                    conditions = {
                      "state == charging" = { string = { text = "Chg {capacity}% "; }; };
                    };
                  };
                }
              ];
            };
          }
        ];
      };
    };
  };
}
