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
#   - bar_enabled = 0 — lemonbar (panels.lemonbar) owns the bar slot.
#   - verbose_layout = 0 — quiet status.
#
# Mango settings with NO spectrwm equivalent (dropped, not faked):
#   - numlockon, repeat_rate, repeat_delay — XKB-level, handled by keyd.
#   - blur, animations, opacity curves, scroller layouts, gapp*, drag_* —
#     spectrwm is a minimal dwm-style tiler; no such knobs.
#
# Keybinds mirror the legion mango aspect as closely as spectrwm's action
# set allows. spectrwm's `bind[KEY] = action` resolves `action` against
# built-ins first, then `program[name]` — so `term`/`launcher`/`locker`/
# `screenshot` are wired via `programs` and the binds reference them by
# name. spectrwm's `MOD` literal in binds is substituted from `modkey`.
{den, ...}: {
  den.aspects.desktop.compositors.spectrwm = {
    includes = [
      den.aspects.desktop.shells.zsh
      # Session furniture: clipboard history (X11), Vietnamese input, bar,
      # notifications, launcher, portals. Same shape as the labwc aspect
      # before it; only the WM-specific bits differ.
      den.aspects.desktop.clipboard.clipmenu
      den.aspects.desktop.input.fcitx5
      den.aspects.desktop.launchers.dmenu
      den.aspects.desktop.panels.lemonbar
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
    in {
      xsession.windowManager.spectrwm = {
        enable = true;
        package = pkgs.spectrwm;

        settings = {
          modkey = "Mod4";
          workspace_limit = 9;
          focus_mode = "manual";
          focus_close = "next";
          border_width = 0;
          # bar_enabled is set to 1 by the lemonbar include (bar.conf)
          # — spectrwm requires bar_enabled = 1 to invoke bar_action.
          # The lemonbar aspect writes bar.conf which sets bar_enabled
          # = 1 and bar_action = ~/.config/spectrwm/bar.sh.
          verbose_layout = 0;
          # Tile layout is the default; spectrwm has no scroller/dwindle
          # split — leave the default (tile).
          # Source the lemonbar config written by panels.lemonbar.
          # spectrwm's `include` keyword takes a path string; the HM
          # settings type accepts strings, so this works.
          include = "${config.home.homeDirectory}/.config/spectrwm/bar.conf";
        };

        # Programs referenced by binds below. spectrwm resolves
        # `bind[KEY] = name` against `program[name]` first, so the binds
        # stay readable.
        programs = {
          term = "${pkgs.st}/bin/st";
          launcher = "${pkgs.dmenu}/bin/dmenu_run";
          # Manual lock (W-Ctrl-l) = direct slock. The idle/suspend
          # lock chain is handled by the xss-lock systemd service in
          # desktop.auth.slock — spawning a second xss-lock here would
          # race with the daemon over the X screensaver.
          locker = "${pkgs.slock}/bin/slock";
          screenshot = "${pkgs.scrot}/bin/scrot";
          # Volume/brightness: spectrwm binds accept arbitrary program
          # names, so XF86 keys spawn wpctl/brightnessctl directly.
          vol_up = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
          vol_down = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          vol_mute = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          bright_up = "${pkgs.unstable.brightnessctl}/bin/brightnessctl set +5%";
          bright_down = "${pkgs.unstable.brightnessctl}/bin/brightnessctl set 5%-";
        };

        # Quirks: float dialogs/popups that should not tile. spectrwm
        # matches by WM_CLASS (substring) and applies the rule.
        quirks = {
          # Float any tool that asks for transient behavior.
          "*" = "TRANSSIENT";
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
          term = "MOD+Return";
          launcher = "MOD+d";
          lock = "MOD+Control+l";
          screenshot = "MOD+Shift+s";

          # --- window management ---
          close = "MOD+q";
          maximize_toggle = "MOD+f";
          fullscreen_toggle = "MOD+Shift+f";
          quit = "MOD+Shift+e";
          restart = "MOD+Shift+r";

          # --- directional focus (mango focusdir h/j/k/l) ---
          focus_left = "MOD+h";
          focus_down = "MOD+j";
          focus_up = "MOD+k";
          focus_right = "MOD+l";

          # --- directional swap (mango exchange_client W-S-h/j/k/l) ---
          swap_left = "MOD+Shift+h";
          swap_down = "MOD+Shift+j";
          swap_up = "MOD+Shift+k";
          swap_right = "MOD+Shift+l";

          # --- workspace navigation (mango viewtoright/left) ---
          ws_left = "MOD+F12";
          ws_right = "MOD+F11";

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

          # --- per-tag send-without-follow (mango SUPER+SHIFT,N,tagsilent) ---
          sendtos_ws_1 = "MOD+Shift+1";
          sendtos_ws_2 = "MOD+Shift+2";
          sendtos_ws_3 = "MOD+Shift+3";
          sendtos_ws_4 = "MOD+Shift+4";
          sendtos_ws_5 = "MOD+Shift+5";
          sendtos_ws_6 = "MOD+Shift+6";
          sendtos_ws_7 = "MOD+Shift+7";
          sendtos_ws_8 = "MOD+Shift+8";
          sendtos_ws_9 = "MOD+Shift+9";

          # --- per-tag send-and-follow (mango SUPER+ALT,N,tag) ---
          sendto_ws_1 = "MOD+Mod1+1";
          sendto_ws_2 = "MOD+Mod1+2";
          sendto_ws_3 = "MOD+Mod1+3";
          sendto_ws_4 = "MOD+Mod1+4";
          sendto_ws_5 = "MOD+Mod1+5";
          sendto_ws_6 = "MOD+Mod1+6";
          sendto_ws_7 = "MOD+Mod1+7";
          sendto_ws_8 = "MOD+Mod1+8";
          sendto_ws_9 = "MOD+Mod1+9";

          # --- media keys (mango bindl XF86*) ---
          vol_up = "XF86AudioRaiseVolume";
          vol_down = "XF86AudioLowerVolume";
          vol_mute = "XF86AudioMute";
          bright_up = "XF86MonBrightnessUp";
          bright_down = "XF86MonBrightnessDown";
        };

        # Disable defaults that conflict with our binds (MOD+q is close,
        # MOD+f is maximize_toggle — spectrwm's defaults already use
        # these, but listing them documents intent and survives upstream
        # default flips).
        unbindings = [
          "MOD+Shift+q" # default quit; we use MOD+Shift+e
        ];
      };

      # DELL session utilities (2026-09-22): screenshots, keys, clipboard,
      # brightness/audio control. All binaries referenced from spectrwm
      # binds and this list use explicit store-path refs so binds cannot
      # silently resolve to the wrong binary.
      home.packages = [
        pkgs.unstable.brightnessctl
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
