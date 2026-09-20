# Waybar — the DELL/labwc session bar (legion uses Noctalia via mangowm).
#
# Config is authored HERE, not left to waybar's shipped default: the default
# config.jsonc uses FontAwesome Private-Use-Area glyphs while the stylix
# waybar target shadows the default style.css with a font that has no icon
# coverage (Maple Mono) — net result was tofu boxes for every module icon
# (2026-09-20). Two-part fix:
#   1. pin stylix.targets.waybar.font = "monospace" to Maple Mono NF CN
#      (modules/features/desktop/theming/stylix.nix) — one font renders text
#      AND Nerd-Font-v3 glyphs;
#   2. this config only uses NF glyphs (verified against labwc 0.9.7's
#      protocol set: ext_workspace_manager_v1, zwlr_foreign_toplevel_manager_v1).
# Style keeps the stylix target (colors/padding) and only overrides the bar's
# own window chrome — per-module rules stay from stylix base.css.
{
  den.aspects.desktop.panels.waybar = {
    homeManager = {
      pkgs,
      lib,
      config,
      ...
    }: {
      programs.waybar = {
        enable = true;
        systemd.enable = true;
        package = pkgs.unstable.waybar;

        settings.mainBar = {
          # Layer shell anchors the bar; position/height drive the wlroots
          # layer surface. 30px ≈ one Maple Mono 10pt line plus padding.
          layer = "top";
          position = "top";
          height = 30;
          spacing = 4;

          modules-left = ["ext/workspaces"];
          modules-center = ["wlr/taskbar"];
          modules-right = [
            "tray"
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "temperature"
            "backlight"
            "battery"
            "clock"
          ];

          # ext/workspaces format-icons keys match workspace NAME (with
          # format {icon}); labwc-desktops names are 1..9, so the digits are
          # themselves — style via #workspaces button in the stylix base.css.
          "ext/workspaces" = {
            format = "{icon}";
            format-icons = {
              "1" = "1";
              "2" = "2";
              "3" = "3";
              "4" = "4";
              "5" = "5";
              "6" = "6";
              "7" = "7";
              "8" = "8";
              "9" = "9";
              active = "";
            };
            sort-by-id = true;
            all-outputs = true;
          };

          "wlr/taskbar" = {
            # Window title instead of per-app icon matching (icon matching
            # needs a maintained app->icon map; the class is enough here).
            format = "{icon}";
            tooltip-format = "{title}";
            on-click = "activate";
            ignore-list = [];
          };

          tray = {
            icon-size = 16;
            spacing = 8;
          };

          pulseaudio = {
            format = "{volume}% {icon}";
            format-muted = "{volume}% 󰖁";
            format-icons = {
              headphone = "󰋋";
              default = ["󰕿" "󰖀" "󰕾"];
            };
            on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };

          network = {
            format-wifi = "󰤨 {essid}";
            format-ethernet = "󰈀 {ipaddr}";
            format-linked = "󰈀 (no IP)";
            format-disconnected = "󰤭";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}  󰅃 {bandwidthDownBytes}  󰅀 {bandwidthUpBytes}";
          };

          cpu.format = "󰻠 {usage}%";
          memory.format = "󰍛 {percentage}%";

          temperature = {
            critical-threshold = 80;
            format = "{temperatureC}°C {icon}";
            format-icons = ["󱃃" "󰔏" "󱐋"];
          };

          backlight = {
            format = "{percent}% {icon}";
            format-icons = ["󰃞" "󰃟" "󰃠"];
          };

          battery = {
            states.warning = 30;
            states.critical = 15;
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% 󰂄";
            format-plugged = "{capacity}% 󰚥";
            format-icons = ["󰁺" "󰁼" "󰁾" "󰂀" "󰁹"];
          };

          clock = {
            format = "󰅐 {:%H:%M}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };
        };

        # Appended AFTER the stylix target's stylesheet (plain `style` from
        # two modules would be a conflicting-definition eval error); waybar
        # concatenates multiple @import-style CSS blocks in definition order,
        # and this block only adds bar chrome on top of stylix's rules.
        style = lib.mkAfter ''
          window#waybar {
            background: alpha(@base00, ${toString config.stylix.opacity.desktop});
            border-bottom: 1px solid @base03;
          }
          #workspaces button {
            min-width: 26px;
          }
        '';
      };
    };
  };
}
