{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "left";
        width = 44;
        margin-top = 0;
        margin-bottom = 0;
        margin-left = 0;
        margin-right = 0;
        spacing = 0;

        modules-left = [
          "custom/power"
          "sway/workspaces"
          "mpris"
        ];

        modules-center = [
          "clock"
        ];

        modules-right = [
          "pulseaudio"
          "backlight"
          "network"
          "battery"
        ];

        "custom/power" = {
          format = " 󰤆 ";
          on-click = "swaynag -t warning -m 'Do you want to exit Sway?' -B 'Yes' 'swaymsg exit'";
          tooltip = false;
        };

        "clock" = {
          format = "{:%d\n%m\n──\n%H\n%M}";
          tooltip = false;
        };

        "sway/workspaces" = {
          disable-scroll = true;
          format = "{name}";
          tooltip = false;
        };

        "mpris" = {
          format = "{artist}-{title}";
          format-playing = "󰏤 {artist}-{title}";
          format-paused = "󰐊 {artist}-{title}";
          rotate = 90;
          max-length = 20;
          min-length = 10;
          on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
          on-scroll-up = "${pkgs.playerctl}/bin/playerctl previous";
          on-scroll-down = "${pkgs.playerctl}/bin/playerctl next";
          tooltip = false;
        };

        "battery" = {
          states = {
            good = 60;
            warning = 30;
            critical = 15;
          };
          format = "{icon}";
          format-alt = " {icon}\n{capacity}";
          format-plugged = "󰂄";
          format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          tooltip = false;
        };

        "network" = {
          format-wifi = " {icon}";
          format-ethernet = "󰈀";
          format-icons = [ "󰤯 " "󰤟 " "󰤢 " "󰤨 " ];
          format-disconnected = "󰪎";
          on-click = "${pkgs.kitty}/bin/kitty -e nmtui";
          interval = 3;
          tooltip = false;
        };

        "backlight" = {
          format-alt = "{icon}";
          format = " {icon}\n{percent}";
          format-icons = [ "" "" "" "" "" "" "" "" "" "" "" "" "" "" ];
          tooltip = false;
        };

        "pulseaudio" = {
          format = "{icon}";
          format-alt = " {icon}\n{volume}";
          format-icons = [ "" "󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥" ];
          format-muted = "";
          on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          tooltip = false;
        };
      };
    };

    style = ''
      * {
        background-color: transparent;
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 16px;
        font-weight: bold;
        border: none;
        box-shadow: none;
        text-shadow: none;
      }

      window#waybar {
        background-color: alpha(@base00, 0.7);
        padding: 0;
        margin: 0;
        border: 0px solid @base05;
        border-radius: 0px;
      }

      .module {
        padding: 8px 4px;
        background-color: alpha(@base05, 0.07);
        border: 0px;
        border-radius: 6px;
        margin: 4px 6px;
      }

      #clock,
      #pulseaudio,
      #backlight,
      #battery,
      #custom-power,
      #mpris,
      #network {
        color: @base05;
      }

      #pulseaudio.muted {
        color: @base00;
        background-color: @base05;
      }

      #battery {
        margin: 4px 6px 10px 6px;
      }

      #custom-power {
        margin: 10px 6px 4px 6px;
      }

      #workspaces {
        background: @base05;
        border-radius: 0px;
        padding: 0;
        margin: 0;
        font-weight: normal;
        font-style: normal;
        opacity: 1;
        font-size: 1px;
      }

      #workspaces button {
        padding: 1px 1px;
        margin: 1px 1px;
        border-radius: 6px;
        color: @base05;
        background-color: @base00;
        transition: all 0.3s ease-in-out;
        font-size: 1px;
        opacity: 0.5;
      }

      #workspaces button:hover {
        background-color: @base00;
        border-radius: 6px;
        min-height: 40px;
      }

      #workspaces button.focused {
        padding: 1px 1px;
        margin: 1px 1px;
        border-radius: 6px;
        background-color: @base00;
        transition: all 0.3s ease-in-out;
        opacity: 1;
      }

      #battery.charging,
      #battery.good:not(.charging),
      #battery.warning:not(.charging),
      #battery.critical:not(.charging) {
        border: 0;
      }

      #battery.good:not(.charging) {
        color: @base05;
      }

      #battery.warning:not(.charging) {
        color: @base09; /* Fallback orange/yellow */
      }

      #battery.critical:not(.charging) {
        color: @base08; /* Fallback red */
        animation: blink 0.6s linear infinite alternate;
      }

      @keyframes blink {
        to {
          color: @base05;
        }
      }
    '';
  };
}