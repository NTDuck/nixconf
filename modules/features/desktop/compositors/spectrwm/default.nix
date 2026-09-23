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
#   - border_width = 0 — mango's borderpx = 0.
#   - bar_enabled = 1 — spectrwm's NATIVE bar (bar.sh/lemonbar pipe
#     model was fictional: bar_action stdout is the bar, stdin is
#     /dev/null — no wsx events; deleted 2026-09-23).
#   - verbose_layout = 0 — quiet status.
#
# Mango settings with NO spectrwm equivalent (dropped, not faked):
#   - numlockon, repeat_rate, repeat_delay — XKB-level, handled by keyd.
#   - blur, animations, opacity curves, scroller layouts, gapp*, drag_* —
#     spectrwm is a minimal dwm-style tiler; no such knobs.
#
# Keybinds mirror the legion mango aspect as closely as spectrwm's action
# set allows. spectrwm's `bind[KEY] = action` resolves `action` against
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
      (den.aspects.desktop.portals.xdg {internalOutput = "eDP-1";})
    ];

    nixos = {pkgs, ...}: {
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
          border_width = 0;
          verbose_layout = 0;
          # Tile layout is the default; spectrwm has no scroller/dwindle
          # split — leave the default (tile).
          #
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
          # COLOR SYNTAX (verified under Xvfb against spectrwm 3.7):
          # hex `#RRGGBB` is REJECTED by xcb_lookup_color on this
          # server ("color '#181616' not found"), and an unescaped `#`
          # starts a comment anyway (fparseln FPARSELN_UNESCCOMM —
          # `bar_color = #181616` became "must supply value"). The
          # core-protocol form works everywhere:
          #   bar_color = rgb:RR/GG/BB
          bar_color = "rgb:${hexToRgb config.lib.stylix.colors.base00-hex}";
          # Session bootstrap (2026-09-22): spawn the autostart script
          # on the first workspace at WM start. The HM xsession script
          # has already activated graphical-session.target by the time
          # this runs, so xss-lock/dunst/clipmenu daemons are up.
          autorun = "ws[1]:${config.home.homeDirectory}/.config/spectrwm/autostart.sh";
        };

        # Programs referenced by binds below. spectrwm resolves
        # `bind[KEY] = name` against `program[name]` first, so the binds
        # stay readable. The st binary is the patched one from
        # desktop.apps.terminals.st (kanagawa-dragon palette + Maple
        # Mono NF CN font), NOT the upstream default.
        programs = {
          term = config.home.sessionVariables.TERMINAL or "${pkgs.st}/bin/st";
          launcher = "${pkgs.dmenu}/bin/dmenu_run";
          # Manual lock (W-Ctrl-l) = direct slock. The idle/suspend
          # lock chain is handled by the xss-lock systemd service in
          # desktop.auth.slock — spawning a second xss-lock here would
          # race with the daemon over the X screensaver.
          # bind[lock] (built-in) spawns program[lock] — the key must be
          # `lock`, not `locker` (spectrwm 3.7 has no program[locker]
          # lookup; the default xlock would run instead).
          lock = "${pkgs.slock}/bin/slock";
          screenshot = "${pkgs.scrot}/bin/scrot";
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
          # --- terminal / launcher / lock / screenshot ---
          # bind[lock] is a BUILT-IN action that spawns program[lock];
          # the program key below is `lock` for exactly that reason.
          term = "MOD+Return";
          launcher = "MOD+d";
          lock = "MOD+Control+l";
          screenshot = "MOD+Shift+s";

          # --- window management ---
          # spectrwm's kill-window action is wind_del — `close` is not
          # in the 3.7 actions table ("invalid action: close" on the
          # 2026-09-23 config-error bar; verified against the source's
          # actions[] table).
          wind_del = "MOD+q";
          maximize_toggle = "MOD+f";
          fullscreen_toggle = "MOD+Shift+f";
          quit = "MOD+Shift+e";
          restart = "MOD+Shift+r";

          # --- focus (spectrwm has NO directional focus — only cycling
          # focus_next/focus_prev, which the binary + man page confirm) ---
          # mango focusdir h/j/k/l → cycle h=prev?? No: mango maps h/j/k/l
          # directionally. spectrwm's only focus motion: focus_next (M-j
          # default), focus_prev (M-k default). Keep mango's keys cycling:
          focus_next = "MOD+l";
          focus_prev = "MOD+k";

          # --- swap (spectrwm has NO directional swap; cycle instead) ---
          swap_prev = "MOD+Shift+h";
          swap_next = "MOD+Shift+l";

          # --- workspace navigation (mango viewtoright/left) ---
          # ws_left/ws_right don't exist; ws_prev/ws_next do.
          ws_prev = "MOD+F12";
          ws_next = "MOD+F11";

          # --- per-tag focus (mango SUPER,N,view,N) ---
          ws_1 = "MOD+1";
          ws_2 = "MOD+2";
          ws_3 = "MOD+3";
          ws_4 = "MOD+4";
          ws_5 = "MOD+5";
          ws_6 = "MOD+6";
          ws_7 = "MOD+7";
          ws_8 = "MOD+8";
          ws_9 = "MOD+9";

          # --- per-tag send (mango SUPER+SHIFT,N,tagsilent) ---
          # spectrwm's send action is mvws_<N> (move window, no follow).
          # There is NO send-and-follow for absolute tags (ws_next_move is
          # relative-only), so mango's SUPER+ALT,N,tag mapping is dropped.
          mvws_1 = "MOD+Shift+1";
          mvws_2 = "MOD+Shift+2";
          mvws_3 = "MOD+Shift+3";
          mvws_4 = "MOD+Shift+4";
          mvws_5 = "MOD+Shift+5";
          mvws_6 = "MOD+Shift+6";
          mvws_7 = "MOD+Shift+7";
          mvws_8 = "MOD+Shift+8";
          mvws_9 = "MOD+Shift+9";

          # --- media keys (mango bindl XF86*) ---
          vol_up = "XF86AudioRaiseVolume";
          vol_down = "XF86AudioLowerVolume";
          vol_mute = "XF86AudioMute";
          bright_up = "XF86MonBrightnessUp";
          bright_down = "XF86MonBrightnessDown";
        };

        # Disable defaults that conflict with our binds. MOD+Shift+q is
        # the default quit — ours is MOD+Shift+e; the default bind would
        # shadow nothing (different key), but spectrwm validates binds
        # against ITS default table: unbind first so a stray MOD+Shift+q
        # can never quit the session.
        unbindings = [
          "MOD+Shift+q"
        ];
      };

      # Session bootstrap spawned by spectrwm's `autorun` setting (see
      # above). Background everything: spectrwm spawns autorun entries
      # sequentially and would block startup otherwise. The idle.sh
      # trigger lives in auth/slock (X screensaver -> xss-lock chain);
      # the wallpaper is the stylix image — X11 has no compositor
      # wallpaper, so feh paints the root window.
      xdg.configFile."spectrwm/autostart.sh" = {
        executable = true;
        text = ''
          #!/bin/sh
          # DELL spectrwm session bootstrap; spawned via spectrwm.conf
          # `autorun`. Everything backgrounds — spectrwm waits on each
          # autorun entry otherwise.
          ${config.home.homeDirectory}/.config/spectrwm/idle.sh &
          ${pkgs.feh}/bin/feh --bg-fill ${config.stylix.image} &
        '';
      };

      # DELL session utilities (2026-09-22): screenshots, keys, clipboard,
      # brightness/audio control. All binaries referenced from spectrwm
      # binds and this list use explicit store-path refs so binds cannot
      # silently resolve to the wrong binary.
      home.packages = [
        pkgs.unstable.brightnessctl
        pkgs.feh # X11 root-window wallpaper (stylix image)
        pkgs.scrot # W-Shift-s screenshots
        pkgs.slurp # region selection helper (paired with scrot -s)
        pkgs.libnotify # notify-send
        pkgs.slock # W-Ctrl-l manual lock (PAM provisioned by HM's security.pam; see auth/slock.nix)
        pkgs.xss-lock # idle/suspend -> slock
        pkgs.wireplumber # wpctl volume control (STABLE: ABI-coupled to system pipewire)
        pkgs.xrandr # display mode control for moonlight-only outputs
      ];
    };
  };
}
