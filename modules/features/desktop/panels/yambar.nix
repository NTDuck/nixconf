# yambar — the DELL/labwc session bar. Replaces waybar (2026-09-21 user
# request). WHY YAMBAR OVER ANOTHER WAYBAR CONFIG: the waybar swap-out was
# driven by the same font issue that killed the first waybar round (tofu
# boxes, see theming/stylix.nix) — yambar's fcft/pango stack takes an
# explicit fontconfig pattern per bar, so the icon font is pinned HERE and
# cannot be shadowed by a stylesheet target the way stylix's waybar
# target shadowed style.css.
#
# Font: "Maple Mono NF CN" — the family resolved and verified via fc-scan
# against pkgs.unstable.maple-mono.NF-CN. It renders latin text, CJK and
# Nerd-Font-v3 glyphs from ONE font, so every glyph in this config is NF.
#
# No workspace module: yambar has no labwc module (man yambar-modules(5),
# 1.11.0: dwl/river/sway/i3 only — labwc workspaces live only in labwc's
# own protocol set), so the left side shows the focused window via
# foreign-toplevel (zwlr_foreign_toplevel_management_v1, part of labwc's
# wlroots 0.19.3 protocol set).
#
# stylix has no yambar target (verified against stylix's module list), so
# the kanagawa-dragon palette is authored here, same as the labwc
# themerc-override in the compositor aspect.
{den, ...}: {
  den.aspects.desktop.panels.yambar = {
    homeManager = {
      pkgs,
      config,
      lib,
      ...
    }: let
      # yambar colors are RRGGBBAA hexstrings (no '#'); opacity.desktop is
      # 0..1 — convert to the two-hex alpha suffix the bar background wants.
      alphaHex = op: lib.fixedWidthString 2 "0" (lib.toHexString (builtins.floor (op * 255)));
      colors = config.lib.stylix.colors;
    in {
      programs.yambar = {
        enable = true;
        package = pkgs.unstable.yambar;
        systemd.enable = true;
        # Same session target the swayidle chain pins (desktop.auth.lockscreen):
        # HM labwc's systemd integration (default-enabled) creates
        # labwc-session.target and links it to graphical-session.target.
        systemd.target = "labwc-session.target";

        settings.bar = {
          # 30px ≈ the waybar height this replaces; one Maple Mono line
          # plus padding.
          height = 30;
          location = "top";
          layer = "top";
          background = "${colors.base00-hex}${alphaHex config.stylix.opacity.desktop}";
          # Bar-level font is inherited by every particle (man
          # yambar-particles(5)); NF CN covers the glyphs used below.
          font = "Maple Mono NF CN:pixelsize=12";

          left = [
            {
              foreign-toplevel.content.map = {
                conditions = {
                  # Only the focused window renders; everything else empty.
                  "~activated" = {empty = {};};
                  activated = [
                    {
                      string = {
                        text = "{app-id}: {title}";
                        max = 60;
                      };
                    }
                  ];
                };
              };
            }
          ];

          right = [
            {
              # Module instantiates content per interface; hide lo and
              # non-carrier links (module has no interface filter option).
              network.content.map = {
                conditions = {
                  "name == \"lo\"" = {empty = {};};
                  "~carrier" = [{string = {text = "󰤭";};}];
                  "carrier && ipv4 != \"\"" = [{string = {text = "󰈀 {name} {ipv4}";};}];
                  carrier = [{string = {text = "󰈀 {name} (no IP)";};}];
                };
              };
            }
            {
              pulse.content.map = {
                conditions = {
                  # No default sink right now (e.g. HDMI-only moments).
                  "~sink_online" = {empty = {};};
                  sink_muted = [{string = {text = "󰖁 {sink_percent}%";};}];
                  "~sink_muted" = [{string = {text = "󰕾 {sink_percent}%";};}];
                };
              };
            }
            {
              # Template runs per core (id >= 0) and once for the total
              # (id == -1); render only the total.
              cpu.content.map = {
                conditions = {
                  "id < 0" = [{string = {text = "󰻠 {cpu}%";};}];
                };
                default = {empty = {};};
              };
            }
            {
              mem.content.string.text = "󰍛 {percent_used}%";
            }
            {
              # E7270 panel backlight — the standard i915 device name.
              backlight = {
                name = "intel_backlight";
                content.string.text = "󰃟 {percent}%";
              };
            }
            {
              battery = {
                name = "BAT0";
                poll-interval = 30000;
                content.map = {
                  conditions = {
                    "state == \"charging\"" = [{string = {text = "󰂄 {capacity}%";};}];
                    "state == \"full\"" = [{string = {text = "󰚥 {capacity}%";};}];
                    "state == \"discharging\" && capacity < 15" = [
                      {
                        string = {
                          text = "󰁺 {capacity}%";
                          foreground = "${colors.base08-hex}ff";
                        };
                      }
                    ];
                    "state == \"discharging\"" = [{string = {text = "󰁹 {capacity}% {estimate}";};}];
                  };
                  # The module docs warn some batteries sit in "unknown"
                  # around ~90% while charging — fall through to the plain
                  # reading instead of hiding the module.
                  default = [{string = {text = "󰁹 {capacity}%";};}];
                };
              };
            }
            {
              clock = {
                time-format = "%H:%M";
                content.string.text = "󰅐 {date} {time}";
              };
            }
          ];
        };
      };
    };
  };
}
