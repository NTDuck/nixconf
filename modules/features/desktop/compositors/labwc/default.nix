{den, ...}: {
  # labwc: stacking wlroots compositor for the DELL streaming client,
  # replacing dwl (2026-09-18). Keybinds mirror the legion mango setup as
  # closely as labwc 0.20.2 allows; the three impossible mappings are
  # documented inline:
  #   - mango `focusdir h/j/k/l` has NO labwc equivalent (no directional
  #     window-focus action exists in any labwc version — verified against
  #     labwc-actions(5) at 0.20.2), so hjkl map to cycling (j/k) and
  #     half-tiling (h/l).
  #   - mango `toggleoverview` (W-a) becomes the window-list menu.
  #   - mango `switch_layout` (W-s) has no layouts in a stacking WM; it
  #     becomes the root menu.
  den.aspects.desktop.compositors.labwc = {
    includes = [
      den.aspects.desktop.shells.zsh
      # Same session furniture the legion mango aspect pulls in: clipboard
      # history and Vietnamese input must live inside the compositor login.
      den.aspects.desktop.clipboard.cliphist
      den.aspects.desktop.input.fcitx5
      # Bar + notifications now live in their own aspects; labwc only wires
      # them into the session.
      den.aspects.desktop.panels.waybar
      den.aspects.desktop.notifications.mako
      den.aspects.desktop.portals.xdg
      {
        internalOutput = "eDP-1";
      }
    ];

    nixos = {
      pkgs,
      config,
      lib,
      ...
    }: {
      programs.labwc = {
        enable = true;
        # tuigreet runs `--cmd ${package}/bin/labwc` directly — the HM labwc
        # module's systemd/env machinery only fires from inside a session it
        # manages, so the session setup is compiled into the binary wrapper
        # (same fix as the dwl aspect before it, 2026-09-18). overrideAttrs
        # (not a writeShellScriptBin) because nixpkgs programs.labwc feeds
        # the package into services.displayManager.sessionPackages, which
        # demands passthru.providedSessions — a bare script has none.
        package = let
          inner = pkgs.labwc;
          wrapped = inner.overrideAttrs (old: {
            nativeBuildInputs =
              (old.nativeBuildInputs or [])
              ++ [pkgs.makeWrapper];

            passthru = (old.passthru or {}) // {providedSessions = ["labwc"];};

            postInstall =
              (old.postInstall or "")
              + ''
                mv $out/bin/labwc $out/bin/labwc-raw
                # PATH must expand $HOME at RUNTIME (the wrapper runs as the
                # logged-in user), hence the --run export rather than
                # --prefix, which bakes the build-time literal
                # (/homeless-shelter).
                # /run/wrappers/bin MUST lead: system-path carries a plain
                # non-setuid sudo (environment.systemPackages gets
                # security.sudo.package), so without the wrappers dir first,
                # `sudo` resolves to that copy and dies with "must be owned
                # by uid 0 and have the setuid bit set" (DELL, 2026-09-19).
                makeWrapper $out/bin/labwc-raw $out/bin/labwc --run 'export PATH="/run/wrappers/bin:$HOME/.nix-profile/bin:$HOME/.local/state/nix/profiles/profile/bin:/run/current-system/sw/bin:$PATH"' --set XDG_CURRENT_DESKTOP labwc --set XDG_SESSION_DESKTOP labwc --set XDG_SESSION_TYPE wayland --set ELECTRON_OZONE_PLATFORM_HINT auto --set MOZ_ENABLE_WAYLAND 1 --set NIXOS_OZONE_WL 1
              '';
          });
        in
          wrapped;
      };

      # Session env vars for login shells/graphical apps started by labwc.
      environment.sessionVariables = {
        XDG_CURRENT_DESKTOP = "labwc";
        XDG_SESSION_DESKTOP = "labwc";
        XDG_SESSION_TYPE = "wayland";
      };
    };

    homeManager = {
      pkgs,
      osConfig,
      config,
      lib,
      ...
    }: {
      wayland.windowManager.labwc = {
        enable = true;
        # Use the NixOS package (the session wrapper above) so greetd, HM and
        # the system agree on one labwc binary.
        package = null;

        # HM labwc renders `rc` through pkgs.formats.xml: attrs → elements,
        # "@key"-style entries → XML attributes, lists → repeated tags.
        rc = let
          # bemenu colors: fb/nb/tb/hb = backgrounds, ff/nf/tf/hf =
          # foregrounds; resolved from the shared stylix palette so the
          # launcher reads like the rest of the session.
          bemenuColors = with config.lib.stylix.colors; {
            fb = base00-hex;
            ff = base05-hex;
            nb = base00-hex;
            nf = base05-hex;
            tb = base0D-hex;
            tf = base00-hex;
            hb = base0D-hex;
            hf = base00-hex;
          };
          bemenu =
            [
              "${pkgs.unstable.bemenu}/bin/bemenu-run"
              "--fn '${config.stylix.fonts.monospace.name} 11'"
              "--prompt run"
            ]
            ++ lib.mapAttrsToList (flag: hex: "--${flag} '#${hex}'") bemenuColors;
        in {
          theme = {
            # themerc-override (below) carries the stylix colors; rc-level
            # theme keeps only what themerc cannot express.
            cornerRadius = 0;
            font = {
              "@name" = config.stylix.fonts.sansSerif.name;
              "@size" = "10";
            };
          };

          # Nine workspaces named 1..9, matching the legion mango tags.
          desktops.names.name = map builtins.toString (lib.range 1 9);

          # Key-input parity with the legion mango aspect (repeat_rate=50,
          # repeat_delay=150, numlockon=1): labwc units match mango's
          # (chars/s, ms; labwc 0.9.7 rc.xml reference, keyboard section).
          keyboard = {
            repeatRate = 50;
            repeatDelay = 150;
            numlock = "on";
            default = true;
            keybind = [
                {
                  "@key" = "W-Return";
                  action = {
                    "@name" = "Execute";
                    "@command" = "${config.programs.foot.package}/bin/footclient";
                  };
                }
                {
                  "@key" = "W-d";
                  action = {
                    "@name" = "Execute";
                    "@command" = lib.concatStringsSep " " bemenu;
                  };
                }
                # W-a: mango toggleoverview -> window list (no overview in labwc).
                {
                  "@key" = "W-a";
                  action = {
                    "@name" = "ShowMenu";
                    menu = "client-list-combined-menu";
                  };
                }
                # W-s: mango switch_layout -> root menu (stacking WM, no layouts).
                {
                  "@key" = "W-s";
                  action = {
                    "@name" = "ShowMenu";
                    menu = "root-menu";
                  };
                }
                {
                  "@key" = "W-q";
                  action = {
                    "@name" = "Close";
                  };
                }
                {
                  "@key" = "W-f";
                  action = {
                    "@name" = "ToggleMaximize";
                  };
                }
                {
                  "@key" = "W-S-f";
                  action = {
                    "@name" = "ToggleFullscreen";
                  };
                }
                {
                  "@key" = "W-S-e";
                  action = {
                    "@name" = "Exit";
                  };
                }
                {
                  "@key" = "W-S-r";
                  action = {
                    "@name" = "Reconfigure";
                  };
                }
                # F11/F12: workspace right/left, mirroring mango viewtoright/left.
                {
                  "@key" = "W-F11";
                  action = {
                    "@name" = "GoToDesktop";
                    "@to" = "right";
                    "@wrap" = "yes";
                  };
                }
                {
                  "@key" = "W-F12";
                  action = {
                    "@name" = "GoToDesktop";
                    "@to" = "left";
                    "@wrap" = "yes";
                  };
                }
                # hjkl: no directional focus exists in labwc (any version), so
                # j/k cycle windows and h/l half-tile — the closest load-bearing
                # equivalents.
                {
                  "@key" = "W-j";
                  action = {
                    "@name" = "NextWindowImmediate";
                  };
                }
                {
                  "@key" = "W-k";
                  action = {
                    "@name" = "PreviousWindowImmediate";
                  };
                }
                {
                  "@key" = "W-h";
                  action = {
                    "@name" = "ToggleSnapToEdge";
                    "@direction" = "left";
                  };
                }
                {
                  "@key" = "W-l";
                  action = {
                    "@name" = "ToggleSnapToEdge";
                    "@direction" = "right";
                  };
                }
                # Mango exchange_client (W-S-h/j/k/l) -> MoveToEdge in the
                # same direction.
                {
                  "@key" = "W-S-h";
                  action = {
                    "@name" = "MoveToEdge";
                    "@direction" = "left";
                  };
                }
                {
                  "@key" = "W-S-l";
                  action = {
                    "@name" = "MoveToEdge";
                    "@direction" = "right";
                  };
                }
                {
                  "@key" = "W-S-k";
                  action = {
                    "@name" = "MoveToEdge";
                    "@direction" = "up";
                  };
                }
                {
                  "@key" = "W-S-j";
                  action = {
                    "@name" = "MoveToEdge";
                    "@direction" = "down";
                  };
                }
                {
                  "@key" = "W-C-l";
                  action = {
                    "@name" = "Execute";
                    "@command" = "${pkgs.unstable.swaylock}/bin/swaylock";
                  };
                }
                {
                  "@key" = "W-S-s";
                  action = {
                    "@name" = "Execute";
                    "@command" = "${pkgs.unstable.grim}/bin/grim";
                  };
                }
                # Media/brightness keys via pipewire + brightnessctl (mango
                # routed these through noctalia, which DELL does not run).
                {
                  "@key" = "XF86MonBrightnessDown";
                  action = {
                    "@name" = "Execute";
                    "@command" = "${pkgs.unstable.brightnessctl}/bin/brightnessctl set 5%-";
                  };
                }
                {
                  "@key" = "XF86MonBrightnessUp";
                  action = {
                    "@name" = "Execute";
                    "@command" = "${pkgs.unstable.brightnessctl}/bin/brightnessctl set +5%";
                  };
                }
                {
                  "@key" = "XF86AudioMute";
                  action = {
                    "@name" = "Execute";
                    "@command" = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
                  };
                }
                {
                  "@key" = "XF86AudioLowerVolume";
                  action = {
                    "@name" = "Execute";
                    "@command" = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
                  };
                }
                {
                  "@key" = "XF86AudioRaiseVolume";
                  action = {
                    "@name" = "Execute";
                    "@command" = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
                  };
                }
              ]
              ++ (lib.map (tag: {
                "@key" = "W-${tag}";
                action = {
                  "@name" = "GoToDesktop";
                  "@to" = tag;
                };
              }) (map builtins.toString (lib.range 1 9)))
              # W-S-tag: mango `tagsilent` -> send window without following.
              ++ (lib.map (tag: {
                "@key" = "W-S-${tag}";
                action = {
                  "@name" = "SendToDesktop";
                  "@to" = tag;
                  "@follow" = "no";
                };
              }) (map builtins.toString (lib.range 1 9)))
              # W-A-tag: mango `tag` -> send window and follow it.
              ++ (lib.map (tag: {
                "@key" = "W-A-${tag}";
                action = {
                  "@name" = "SendToDesktop";
                  "@to" = tag;
                  "@follow" = "yes";
                };
              }) (map builtins.toString (lib.range 1 9)));
          };
        };
        autostart = [
          # Only the input method needs an explicit start: mako and waybar
          # start via their own systemd user units, and the HM labwc module
          "${osConfig.i18n.inputMethod.package}/bin/fcitx5 -d -r &"
        ];
        # The labwc binary wrapper only sets env for the compositor process
        # itself; this import (appended to ~/.config/labwc/autostart by the HM
        # module) propagates the session vars into systemd/dbus so user
        # services and portals see them. Superset of the module default.
        systemd.variables = [
          "DISPLAY"
          "WAYLAND_DISPLAY"
          "XDG_CURRENT_DESKTOP"
          "XDG_SESSION_DESKTOP"
          "XDG_SESSION_TYPE"
        ];
      };

      # Kanagawa-dragon window furniture from the shared stylix palette —
      # stylix has no labwc target (verified against stylix module list), so
      # the theme file is authored here.
      xdg.configFile."labwc/themerc-override".text = with config.lib.stylix.colors; ''
        border.width: 1
        window.active.border.color: #${base0D-hex}
        window.inactive.border.color: #${base03-hex}
        window.active.title.bg.color: #${base00-hex}
        window.inactive.title.bg.color: #${base00-hex}
        window.active.label.text.color: #${base05-hex}
        window.inactive.label.text.color: #${base04-hex}
        window.label.text.justify: Center
        menu.items.bg.color: #${base00-hex}
        menu.items.text.color: #${base05-hex}
        menu.items.active.bg.color: #${base0D-hex}
        menu.items.active.text.color: #${base00-hex}
      '';

      # DELL session utilities (2026-09-18 user request): launcher,
      # screenshots, keys, clipboard, brightness/audio control. All binaries
      # referenced from rc keybinds and this list use explicit store-path refs
      # so labwc keybinds cannot silently resolve to the wrong binary. Bar and
      # notifications moved to their own aspects (panels.waybar,
      # notifications.mako).
      home.packages = [
        pkgs.unstable.bemenu # W-d launcher (bemenu-run)
        pkgs.unstable.brightnessctl
        pkgs.unstable.grim # W-S-s screenshots
        pkgs.unstable.slurp # region selection helper for grim
        pkgs.unstable.libnotify # notify-send
        pkgs.unstable.swaylock # W-C-l lock (PAM service comes from programs.labwc)
        pkgs.unstable.wl-clipboard
        pkgs.wireplumber # wpctl volume control (STABLE: ABI-coupled to system pipewire)
        pkgs.unstable.wlr-randr # display mode control for moonlight-only outputs
      ];
    };
  };
}
