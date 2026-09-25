# spectrwm: small dynamic tiling X11 window manager for the DELL streaming
# client, replacing labwc (2026-09-22). Configured idiomatically via HM's
# `xsession.windowManager.spectrwm` (verified against
# https://mynixos.com/home-manager/options/xsession.windowManager.spectrwm
# and the upstream module at
# https://github.com/nix-community/home-manager/blob/release-26.05/modules/services/window-managers/spectrwm.nix).
#
# Port map from mangowm (only what's expressible in spectrwm's
# settings/bindings/programs/quirks/unbindings):
#   - modkey = Mod4 (WINKY) — matches mango's SUPER.
#   - workspace_limit = 9 — mango uses 9 tags.
#   - focus_mode = manual — mango's focus_on_activate = 0.
#   - focus_close = next — closest mango analog (default is "prev").
#   - border_width = 0, tile_gap = 6, region_padding = 6 — mango's
#     borderpx = 0 with 6px inner/outer gaps (gappi*/gappo* = 6;
#     2026-09-24 evening: user restored outer margins, reverting the
#     same-day zero-outer-margin trial. See margins note below.)
#   - bar_enabled = 1 — spectrwm's NATIVE bar (bar.sh/lemonbar pipe
#     model was fictional: bar_action stdout is the bar, stdin is
#     /dev/null — no wsx events; deleted 2026-09-23). From 2026-09-24
#     the bar is laid out via bar_format sections: workspaces left,
#     clock middle, light/audio/battery right (swm-status script).
#   - verbose_layout = 0 — quiet status.
#
# Mango settings with NO spectrwm equivalent (dropped, not faked):
#   - numlockon — skipped deliberately: the E7270 has no numpad, so the
#     parity setting would be a no-op here (2026-09-24).
#   - repeat_rate/repeat_delay — no WM knob, set at the X SERVER level
#     instead: -ardelay 150 -arinterval 20 on the dell-x11-session
#     wrapper (2026-09-24; X defaults were 660 ms / 25 cps).
#   - blur, animations, opacity curves, scroller layouts, gapp*, drag_* —
#     spectrwm is a minimal dwm-style tiler; no such knobs.
#
# Keybinds (2026-09-24 evening, user request): mango's keymap mapped
# onto spectrwm's closest actions (wind_del M-q, cycle_layout M-s,
# maximize/fullscreen M-f/M-S-f, reload M-S-r; see bindings).
# spectrwm's `bind[KEY] = action` resolves `action` against
# built-ins first, then `program[name]` — so `term`/`launcher`/`lock`/
# `screenshot` are wired via `programs` and the binds reference them by
# name. spectrwm's `MOD` literal in binds is substituted from `modkey`.
#
# Session startup (2026-09-22): tuigreet launches the wrapped spectrwm
# binary, not HM's xsession script (xsession.enable stays false — the
# session lives under greetd, and HM's xsession module asserts its own
# script only fires when IT manages the session). Without activation,
# graphical-session.target stays down and user services bound to it
# (xss-lock, dunst, clipmenu) never start. The wrapper mirrors the old
# labwc aspect: export session env vars, start the HM graphical target,
# then exec spectrwm.
{den, ...}: {
  den.aspects.desktop.compositors.spectrwm = {
    includes = [
      den.aspects.desktop.shells.zsh
      # Session furniture: clipboard history (X11), Vietnamese input,
      # notifications, launcher, portals. Same shape as the labwc aspect
      # before it; only the WM-specific bits differ.
      den.aspects.desktop.clipboard.clipmenu
      den.aspects.desktop.input.fcitx5
      den.aspects.desktop.launchers.dmenu
      den.aspects.desktop.notifications.dunst
      # i3lock + xss-lock (X11 idle chain; PAM + xss-lock service live
      # in the i3lock aspect).
      den.aspects.desktop.auth.i3lock
      # Portals (2026-09-24): X11 session — the wlr ScreenCast/Screenshot
      # backend (xdg-desktop-portal-wlr) is wlroots/Wayland-only and was
      # a labwc-era leftover; passing wlr = false drops it from the
      # closure (the GTK portal covers Screenshot on X11).
      (den.aspects.desktop.portals.xdg {
        internalOutput = "eDP-1";
        wlr = false;
      })
    ];

    nixos = {pkgs, ...}: {
      # PATCHED spectrwm (2026-09-25): update_floater()'s MAXIMIZED
      # branch used rf->g_usable raw, so a maximized window sat flush
      # against the screen edges while tiled windows kept the
      # region_padding margin (user: "when window is maximized, it
      # still have margin to the screen borders"). The patch mirrors
      # stack()'s inset. Overlay, not a systemPackages-local override:
      # the HM xsession module launches `package = pkgs.spectrwm`
      # separately — only an overlay patches both consumers. No config
      # knob exists for this (source-verified against 3.7.0); upstream
      # material if it survives.
      nixpkgs.overlays = [
        (final: prev: {
          spectrwm = prev.spectrwm.overrideAttrs (old: {
            # patchPhase runs with cwd = sourceRoot = source/linux, but
            # spectrwm.c sits at source/ — one level up — and GNU patch
            # refuses `..` in -p1 filenames. Apply with `-d .. -p0`
            # instead (header paths are `spectrwm.c`).
            prePatch = ''
              # patch needs write on the FILE (store sources are
              # read-only) AND on the DIRECTORY for its temp files.
              chmod u+w .. ../spectrwm.c
              patch -d .. -p0 < ${
                ./maximize-region-padding.patch
              }
            '';
          });
        })
      ];

      # spectrwm ships no NixOS module (verified against nixpkgs
      # release-26.05 nixos/modules/programs/x11/ — no spectrwm.nix), so
      # the package is exposed via environment.systemPackages and the
      # session is started by HM's xsession.windowManager.command.
      environment.systemPackages = [
        pkgs.spectrwm
      ];

      # Session env vars for login shells/graphical apps started by
      # spectrwm. XDG_CURRENT_DESKTOP must be a registered name for
      # xdg-desktop-portal to pick the right backend; "spectrwm" is
      # accepted by the portal's fallback list.
      environment.sessionVariables = {
        XDG_CURRENT_DESKTOP = "spectrwm";
        XDG_SESSION_DESKTOP = "spectrwm";
        XDG_SESSION_TYPE = "x11";
      };
    };

    homeManager = {
      pkgs,
      config,
      lib,
      ...
    }: let
      tags = map builtins.toString (lib.range 1 9);
      # "181616" → "18/16/16" (spectrwm's core-protocol color form).
      hexToRgb = h: "${builtins.substring 0 2 h}/${builtins.substring 2 2 h}/${builtins.substring 4 2 h}";

      # Bar status script (2026-09-24 evening): light, volume, battery
      # feeding bar_format's +A section. PERSISTENT loop, not one-shot:
      # spectrwm reads bar_action output from ITS OWN STDIN
      # (bar_extra_update() in spectrwm.c) and treats pipe EOF as
      # "bar_action failed" — a one-shot script is dead after its
      # first line, and the dell booted into exactly that wedge (right
      # section empty from the 22:07 boot until a USR1 reload; the
      # same conf rendered fully under Xvfb, so this was a boot race
      # on the EOF, not a config bug). Upstream's own baraction.sh is
      # a while-loop for the same reason: keep the pipe open. The loop
      # re-echoes the line every 5s (brightness/volume/battery drift
      # slowly; the %H:%M clock in bar_format is rendered by spectrwm
      # itself and stays 1s-fresh). Binaries are explicit store paths
      # so the bar can never resolve a wrong binary. writeShellScript
      # runs this under bash with set -euo pipefail, hence the || true
      # guards.
      swm-status = pkgs.writeShellScript "swm-status" ''
        # Nerd Font glyphs as $'…' escapes (raw UTF-8 got mangled in the
        # nix file round-trip). NOTE: $'…' only expands OUTSIDE double
        # quotes, so each glyph is assigned first, then interpolated.
        g_bolt=$'\uf0e7' # brightness / charging
        g_vol=$'\uf028' # nf-fa-volume_up
        g_mute=$'\uf026' # nf-fa-volume_off
        g_bat_full=$'\uf240'
        g_bat_34=$'\uf241'
        g_bat_12=$'\uf242'
        g_bat_low=$'\uf243'
        g_bat_empty=$'\uf244'

        status() {
          light=""
          pct=$(${pkgs.unstable.brightnessctl}/bin/brightnessctl get 2>/dev/null || true)
          max=$(${pkgs.unstable.brightnessctl}/bin/brightnessctl max 2>/dev/null || true)
          # max-zero guard: divide-by-zero would abort the whole line.
          if [ -n "$pct" ] && [ -n "$max" ] && [ "$max" -gt 0 ]; then
            light="$g_bolt $((pct * 100 / max))%"
          fi

          vol=""
          vol_out=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)
          case "$vol_out" in
            *Volume:*)
              raw=''${vol_out#*Volume: }
              case "$raw" in
                # wpctl appends " [MUTED]" to the same Volume line.
                *MUTED*) vol="$g_mute muted" ;;
                *)
                  case "$raw" in
                    0.*) raw=''${raw#0.} ;; # 0.45 → 45 (10#05 → 5 too)
                    *) raw=''${raw//./} ;; # 1.00 → 100 (wpctl caps at 1.00)
                  esac
                  [ -n "$raw" ] || raw=0
                  vol="$g_vol $((10#$raw))%"
                  ;;
              esac
              ;;
          esac

          bat=""
          for bat_dir in /sys/class/power_supply/BAT*; do
            # Glob stays literal when no battery exists; -r fails and we
            # skip, leaving the battery segment out entirely (AC-only
            # desktops must not show a dead cell).
            [ -r "$bat_dir/capacity" ] || continue
            cap=$(${pkgs.coreutils}/bin/cat "$bat_dir/capacity")
            [ -n "$cap" ] || continue
            if [ "$cap" -ge 90 ]; then icon=$g_bat_full
            elif [ "$cap" -ge 70 ]; then icon=$g_bat_34
            elif [ "$cap" -ge 50 ]; then icon=$g_bat_12
            elif [ "$cap" -ge 30 ]; then icon=$g_bat_low
            else icon=$g_bat_empty
            fi
            suffix=""
            if [ "$(${pkgs.coreutils}/bin/cat "$bat_dir/status")" = "Charging" ]; then
              suffix=" $g_bolt"
            fi
            bat=" $icon $cap%$suffix"
            break
          done

          echo "$light   $vol   $bat"
        }
        # EVENT-DRIVEN (2026-09-25): the original while/sleep-5 poll
        # made every status change wait up to 5s to hit the bar (user:
        # "bar is supposed to be event based … brightness takes a few
        # seconds"). Now: a monitor process inotify-watches the
        # backlight + battery sysfs files and pings a FIFO on every
        # change; the emitter prints instantly on each ping, or wakes
        # at most 2s for volume (no file surface — wpctl has no
        # watchable node). Same EOF contract as before: the pipe to
        # spectrwm's stdin must NEVER close while spectrwm lives.
        fifo=$(${pkgs.coreutils}/bin/mktemp -u)
        ${pkgs.coreutils}/bin/mkfifo "$fifo"
        # Reload/quit respawns this script; without the trap each cycle
        # would leak one FIFO node in /tmp. HUP/TERM needed: bash skips
        # the EXIT trap when killed by an unhandled signal, and
        # spectrwm stops bar_action with SIGTERM (kill_bar_extra).
        trap '${pkgs.coreutils}/bin/rm -f "$fifo"' EXIT INT TERM HUP

        # One emitter only: spawn a replacement monitor if it dies.
        monitor() {
          while :; do
            ${pkgs.inotify-tools}/bin/inotifywait -q -e modify \
              /sys/class/backlight/intel_backlight/brightness \
              /sys/class/backlight/intel_backlight/max_brightness \
              /sys/class/power_supply/BAT*/capacity \
              /sys/class/power_supply/BAT*/status 2>/dev/null \
              | while read -r _; do
                  ${pkgs.coreutils}/bin/echo 1 > "$fifo"
                done
            ${pkgs.coreutils}/bin/sleep 1 # inotify watch died; retry
          done
        }
        monitor &
        mon_pid=$!

        last=""
        while :; do
          line="$(status)"
          # Dedup: only print when the rendered line actually changed.
          if [ "$line" != "$last" ]; then
            echo "$line"
            last="$line"
          fi
          # 2s watchdog: volume drift (no file event), missed pings.
          ${pkgs.coreutils}/bin/timeout 2 \
            ${pkgs.coreutils}/bin/cat "$fifo" >/dev/null 2>&1 || true
        done
      '';
    in {
      # HM's xsession module owns the session lifecycle: ~/.xsession
      # starts hm-graphical-session.target BEFORE the WM runs and stops
      # it after. tuigreet invokes ~/.xsession (see dell host greeter).
      xsession.enable = true;

      xsession.windowManager.spectrwm = {
        enable = true;
        package = pkgs.spectrwm;

        settings = {
          modkey = "Mod4";
          workspace_limit = 9;
          focus_mode = "manual";
          focus_close = "next";
          # Margins (2026-09-25): border_width=0 since 0d8784f; outer
          # margin region_padding walked 0 → 6 (mango parity) → 4
          # (2026-09-25 user: "windows must have margin to outer screen
          # borders", amended 2px → 4px within the minute). tile_gap
          # stays 6 (mango inner gap; user asked only about the OUTER
          # margin).
          border_width = 0;
          tile_gap = 6;
          region_padding = 4;
          verbose_layout = 0;
          # Tile layout is the default; spectrwm has no scroller/dwindle
          # split — leave the default (tile).
          # CONFIG-ERROR ROOT CAUSE (2026-09-23): spectrwm 3.7 has NO
          # `include` directive (verified against the 3.7 source's
          # configopt table) — the previous `include = …/bar.conf` line
          # raised "unknown option: include", which spectrwm surfaces in
          # its bar as a startup exception (the on-screen "config
          # error"). bar.conf is gone; the bar is spectrwm's NATIVE bar:
          # bar_action's stdout is the bar and its stdin is /dev/null,
          # so the lemonbar/wsx-pipe model never existed — dropped.
          bar_enabled = 1;
          bar_font = "Maple Mono NF CN:size=10";
          # Bar layout (2026-09-24 request): workspaces left, clock
          # middle, light/audio/battery right. +|L/C/R pin the sections;
          # +L renders the workspace list, %H:%M the clock, +A the
          # bar_action script's stdout (single line, see swm-status).
          bar_format = "+|L+L+|C%H:%M+|R+A";
          # bar_action writes plain text — expand=1 lets spectrwm feed
          # it through bar_format escape processing each refresh.
          bar_action = "${swm-status}";
          bar_action_expand = 1;
          # Workspace list capped at 9 (mango-parity tag count).
          bar_workspace_limit = 9;
          # 2026-09-25: frame removed — the 2px base0B border read as a
          # "bar bottom margin" against the base00 background. Bar is
          # now a flush base00 strip; alignment still comes from the
          # selected-workspace marker (base0B).
          bar_border_width = 0;
          # bar_ padding_* = text inset INSIDE the bar window (man:
          # "status bar horizontal/vertical padding"); the bar window
          # itself always spans the full region — no inset knob exists
          # (knob inventory verified against the 3.7 man page). Matching
          # the 4px window margin makes bar text align with window text
          # against the screen edge.
          bar_padding_horizontal = 4;
          bar_padding_vertical = 2;
          # Readable fg on the base00 bar; accent (base0B) for the
          # selected workspace marker. Same rgb:RR/GG/BB form as
          # bar_color above (hex `#` is rejected/comment-start).
          bar_font_color = "rgb:${hexToRgb config.lib.stylix.colors.base04-hex}";
          bar_font_color_selected = "rgb:${hexToRgb config.lib.stylix.colors.base0B-hex}";
          # COLOR SYNTAX (verified under Xvfb against spectrwm 3.7):
          # hex `#RRGGBB` is REJECTED by xcb_lookup_color on this
          # server ("color '#181616' not found"), and an unescaped `#`
          # starts a comment anyway (fparseln FPARSELN_UNESCCOMM —
          # `bar_color = #181616` became "must supply value"). The
          # core-protocol form works everywhere:
          #   bar_color = rgb:RR/GG/BB
          bar_color = "rgb:${hexToRgb config.lib.stylix.colors.base00-hex}";
          # (2026-09-24) The `spawn_flags = "nospawnws"` line that stood
          # here is REVERTED: the libswmhack spawn-deadlock theory was
          # falsified — gen 24 had nospawnws and still froze identically,
          # and the dwm era (no libswmhack at all) froze identically too.
          # The real cause was Xorg starting with ZERO input drivers
          # (xinit's startx bakes the raw xorgserver as its default
          # server, whose ModulePath lacks libinput/evdev) — fixed in the
          # dell host via /etc/X11/xorg.conf.d/00-modulepath.conf. Xvfb
          # A/B tests passed because XTEST key injection bypasses input
          # drivers entirely. Default spawn behavior (workspace-targeted
          # spawn via libswmhack) is restored.
          # Session bootstrap (2026-09-22): spawn the autostart script
          # on the first workspace at WM start. The HM xsession script
          # has already activated graphical-session.target by the time
          # this runs, so xss-lock/dunst/clipmenu daemons are up.
          autorun = "ws[1]:${config.home.homeDirectory}/.config/spectrwm/autostart.sh";
        };

        # Programs referenced by binds below. spectrwm resolves
        # `bind[KEY] = name` against `program[name]` first, so the binds
        # stay readable. The terminal is the PATCHED st
        # (apps.terminals.st: stylix palette + Maple Mono NF CN baked
        # into config.def.h); the fallback pins the patched binary's
        # session path — the bare pkgs.st here would be the UNPATCHED
        # binary, but TERMINAL is always set by the st aspect, so the
        # fallback only exists to keep eval total.
        programs = {
          term =
            config.home.sessionVariables.TERMINAL
            or "${pkgs.st}/bin/st";
          launcher = "${pkgs.dmenu}/bin/dmenu_run";
          # Manual lock (W-Ctrl-l) = direct i3lock. The idle/suspend
          # lock chain is handled by the xss-lock systemd service in
          # desktop.auth.i3lock — spawning a second xss-lock here would
          # race with the daemon over the X screensaver.
          # -n (--nofork): xss-lock waits for the locker process to
          # exit before resuming its event loop; plain i3lock forks a
          # child and exits the parent, which breaks the chain.
          # -c: fill color, hex WITHOUT '#' prefix (i3lock's -c format
          # matches stylix's base00-hex output directly).
          # bind[lock] (built-in) spawns program[lock] — the key must be
          # `lock`, not `locker` (spectrwm 3.7 has no program[locker]
          # lookup; the default xlock would run instead).
          lock = "${pkgs.i3lock}/bin/i3lock -n -c ${config.lib.stylix.colors.base00-hex}";
          screenshot = "${pkgs.scrot}/bin/scrot";
          # W-b: firefox browser (falkon removed 2026-09-24). Must be
          # finalPackage: HM bakes programs.firefox.policies into the
          # finalPackage's distribution/policies.json (force-installs
          # betterdeepseek); the bare pkgs.firefox store path carries
          # no policies. Guarded because the spectrwm aspect is
          # firefox-independent in principle.
          browser =
            if config.programs.firefox.enable or false
            then "${config.programs.firefox.finalPackage}/bin/firefox"
            else "${pkgs.unstable.firefox}/bin/firefox";
          # Volume/brightness: spectrwm binds accept arbitrary program
          # names, so XF86 keys spawn wpctl/brightnessctl directly.
          vol_up = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
          vol_down = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          vol_mute = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          bright_up = "${pkgs.unstable.brightnessctl}/bin/brightnessctl set +5%";
          bright_down = "${pkgs.unstable.brightnessctl}/bin/brightnessctl set 5%-";
        };

        # Quirks: float dialogs/popups that should not tile. Selector is
        # an ERE matched against WM_CLASS; flags are space-separated.
        quirks = {
          # Selector is a REGEX (upstream format class[:instance]:
          # [role]:[type]); bare "*" is a dangling-quantifier regex and
          # raises "invalid regex for class field" — use ".*".
          ".*" = "TRANSSZ";
          # Common dialogs.
          Pavucontrol = "FLOAT";
          Arandr = "FLOAT";
          Lxappearance = "FLOAT";
          # File-chooser dialogs.
          "file-roller" = "FLOAT";
          "Pcmanfm" = "FLOAT";
        };

        bindings = {
          # KEYMAP PARITY (2026-09-24): i3's defaults, mapped onto
          # spectrwm's closest actions (user request "make controls like
          # i3"). Divergences are forced by spectrwm's action table and
          # noted inline. Verified default-table conflicts per key
          # against the 3.7 man page (lines 1498-1643); freed keys are
          # unbound below so no stock action resurfaces.

          # --- terminal / launcher / lock / screenshot ---
          # bind[lock] is a BUILT-IN action that spawns program[lock];
          # the program key below is `lock` for exactly that reason.
          term = "MOD+Return";
          launcher = "MOD+d";
          browser = "MOD+b";
          lock = "MOD+Control+l";
          screenshot = "MOD+Shift+s";

          # --- window management (mango parity, 2026-09-24 evening) ---
          # Mango: SUPER,q killclient; SUPER,f togglemaximizescreen;
          # SUPER+SHIFT,f togglefullscreen; SUPER+SHIFT,e quit;
          # SUPER+SHIFT,r reload_config. spectrwm's kill action is
          # wind_del — `close` is not in the 3.7 actions table
          # ("invalid action: close" on the 2026-09-23 config-error bar;
          # verified against the source's actions[] table). Mango has
          # no restart bind, so spectrwm's restart stays unbound
          # (SIGHUP and quit paths remain). float_toggle keeps
          # M-S-space: mango binds no SUPER+SHIFT,space, and fcitx5
          # owns plain M-space.
          wind_del = "MOD+q";
          maximize_toggle = "MOD+f";
          fullscreen_toggle = "MOD+Shift+f";
          float_toggle = "MOD+Shift+space";
          reload = "MOD+Shift+r";
          quit = "MOD+Shift+e";

          # --- focus (spectrwm has NO directional focus — only cycling
          # focus_next/focus_prev, which the binary + man page confirm;
          # i3's M-j/M-k directional keys map onto the cycle) ---
          # M-j/M-k are spectrwm's NATIVE cycle keys, so focus_next
          # moves off the default M-l — that bind clobbered the built-in
          # master_grow. No h/l binds: h/l keep their
          # master_shrink/master_grow defaults (spectrwm 3.7 has no
          # directional focus to map them to).
          focus_next = "MOD+j";
          focus_prev = "MOD+k";

          # --- layout cycling (mango parity, 2026-09-24 evening) ---
          # Mango: SUPER,s switch_layout → cycle_layout on M-s
          # (overrides the default screenshot_all there). M-e is freed
          # entirely: mango binds no SUPER,e and the default
          # maximize_toggle moved to M-f — unbound below.
          cycle_layout = "MOD+s";

          # --- swap (spectrwm has NO directional swap; cycle instead) ---
          swap_prev = "MOD+Shift+h";
          swap_next = "MOD+Shift+l";

          # --- workspace navigation (i3 has no default prev/next) ---
          # ws_left/ws_right don't exist; ws_prev/ws_next do (F11/F12).
          ws_prev = "MOD+F12";
          ws_next = "MOD+F11";

          # --- per-tag focus (i3 Mod+N workspace N) ---
          ws_1 = "MOD+1";
          ws_2 = "MOD+2";
          ws_3 = "MOD+3";
          ws_4 = "MOD+4";
          ws_5 = "MOD+5";
          ws_6 = "MOD+6";
          ws_7 = "MOD+7";
          ws_8 = "MOD+8";
          ws_9 = "MOD+9";

          # --- per-tag send (i3 Mod+Shift+N move container to N) ---
          # spectrwm's send action is mvws_<N> (move window, no follow).
          # There is NO send-and-follow for absolute tags (ws_next_move is
          # relative-only); mvws moves without following — accepted
          # divergence from i3's move+follow.
          mvws_1 = "MOD+Shift+1";
          mvws_2 = "MOD+Shift+2";
          mvws_3 = "MOD+Shift+3";
          mvws_4 = "MOD+Shift+4";
          mvws_5 = "MOD+Shift+5";
          mvws_6 = "MOD+Shift+6";
          mvws_7 = "MOD+Shift+7";
          mvws_8 = "MOD+Shift+8";
          mvws_9 = "MOD+Shift+9";

          # --- media keys (i3 bindl XF86* equivalents) ---
          vol_up = "XF86AudioRaiseVolume";
          vol_down = "XF86AudioLowerVolume";
          vol_mute = "XF86AudioMute";
          bright_up = "XF86MonBrightnessUp";
          bright_down = "XF86MonBrightnessDown";
        };

        # Disable defaults for keys our map leaves empty (default
        # table verified in the 3.7 man page). MOD+Shift+q is the
        # default quit — wind_del moved to M-q (mango parity), so free
        # M-S-q so a stray press can never quit the session. MOD+e
        # default maximize_toggle moved to M-f; MOD+w default iconify
        # freed (mango has no SUPER,w). MOD+Space (default
        # cycle_layout, spectrwm 3.7 man line ~1508) is freed for
        # fcitx5's input-method trigger (Super+space, i18n.inputMethod
        # config) — keypress never reached fcitx5 while spectrwm held
        # the grab. NOTE: keysym must be lowercase `space` —
        # `bind[]: invalid key: Space` kills the whole bar render
        # (Xvfb-reproduced 2026-09-24).
        # CAUTION (2026-09-24, the original W+q killer): HM emits
        # unbindings AFTER binds in the generated conf, and an unbind
        # for a key a bind[] above uses silently disables that bind —
        # wind_del=M-S-q was dead on arrival exactly this way. Never
        # list a key a bind above consumes.
        unbindings = [
          "MOD+Shift+q"
          "MOD+e"
          "MOD+w"
          "MOD+space"
        ];
      };

      # Session bootstrap spawned by spectrwm's `autorun` setting (see
      # above). Background everything: spectrwm spawns autorun entries
      # sequentially and would block startup otherwise. The wallpaper
      # is the stylix image — X11 has no compositor wallpaper, so feh
      # paints the root window.
      xdg.configFile."spectrwm/autostart.sh" = {
        executable = true;
        text = ''
          #!/bin/sh
          # DELL spectrwm session bootstrap; spawned via spectrwm.conf
          # `autorun`. Everything backgrounds — spectrwm waits on each
          # autorun entry otherwise.
          # "Never dim/sleep when idle" (2026-09-21): kill the X
          # screensaver timer (which screen-locker's ExecStartPre set to
          # 600s for auto-lock) and DPMS blanking. The autostart runs
          # AFTER the xss-lock unit's ExecStartPre, so this wins. Locking
          # stays MANUAL (W-Ctrl-l) plus the suspend path (--transfer-
          # sleep-lock); nothing auto-locks or blanks on idle.
          ${pkgs.xorg.xset}/bin/xset s off -dpms &
          ${pkgs.feh}/bin/feh --bg-fill ${config.stylix.image} &
        '';
      };

      # DELL session utilities (2026-09-23): screenshots, keys, clipboard,
      # brightness/audio control. All binaries referenced from spectrwm
      # binds and this list use explicit store-path refs so binds cannot
      # silently resolve to the wrong binary. Lock packages live in
      # desktop.auth.i3lock (i3lock via programs.i3lock, xss-lock via
      # services.screen-locker).
      home.packages = [
        pkgs.unstable.brightnessctl
        pkgs.feh # X11 root-window wallpaper (stylix image)
        pkgs.scrot # W-Shift-s screenshots; also does its own X11 region select
        # slurp removed (2026-09-24): wlroots/Wayland-only selector, labwc-era
        # leftover; scrot -s covers region selection on X11.
        pkgs.libnotify # notify-send
        pkgs.wireplumber # wpctl volume control (STABLE: ABI-coupled to system pipewire)
        pkgs.xrandr # display mode control for moonlight-only outputs
      ];
    };
  };
}
