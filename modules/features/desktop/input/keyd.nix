{den, ...}: {
  den.aspects.desktop.input.keyd = {
    nixos = {pkgs, ...}: let
      keyd-numlock-sync = pkgs.writeShellScriptBin "keyd-numlock-sync" ''
        set -eu
        truth=
        for led in /sys/class/leds/*::numlock; do
          [ -e "$led" ] || continue
          if [ "$(cat "$led/device/name" 2>/dev/null || :)" = "keyd virtual keyboard" ]; then
            truth="$led/brightness"
          fi
        done
        # No virtual device yet (keyd still starting): exit quietly, the
        # timer retries.
        [ -n "$truth" ] || exit 0
        state=$(cat "$truth")
        for led in /sys/class/leds/*::numlock; do
          [ -e "$led" ] || continue
          [ "$(cat "$led/device/name" 2>/dev/null || :)" = "keyd virtual keyboard" ] && continue
          [ "$(cat "$led/brightness")" = "$state" ] || echo "$state" > "$led/brightness"
        done
      '';
    in {
      services.keyd = {
        enable = true;
        package = pkgs.unstable.keyd;

        keyboards = {
          rpgm = {
            ids = ["*"];

            settings = {
              # NumLock must stay a REAL NumLock (2026-09-16): keyd's
              # toggle(nav) on it swallows the raw KEY_NUMLOCK/LED_NUML
              # events, so the laptop's NumLock indicator never lights.
              # The nav layer is held with rightalt instead — hold
              # rightalt+w/a/s/d for arrows, e/q for enter/esc.
              main = {
                rightalt = "layer(nav)";
              };

              nav = {
                w = "up";
                a = "left";
                s = "down";
                d = "right";

                e = "enter";
                q = "esc";
              };
            };
          };
        };
      };

      # NumLock LED desync fix (2026-09-21): keyd 2.6.0 propagates LED
      # events ONE-WAY, virtual -> grabbed physicals (src/daemon.c:572,
      # "Propagate LED events received by the virtual device from
      # userspace to all grabbed devices"); nothing pushes state in the
      # other direction or at device (re)initialization. Any event that
      # resets/sets physical LEDs outside the compositor — resume from
      # suspend (hardware LEDs reset), VT switch (kernel TTY layer),
      # keyd restart (new uinput device, no initial push), hotplug —
      # leaves the physical LED stale while mango/wlroots keep their
      # own state on the virtual device (mango numlockon=1, 2026-09-19).
      # Fix: mirror every physical numlock LED from the keyd virtual
      # keyboard node. The virtual node is the session's source of
      # truth (wlroots writes it on every toggle and it survives
      # resume), so this converges without ever inventing state.
      # Sweep cadence covers boot (OnBootSec races keyd's uinput
      # creation), keyd restarts and slow hotplug; a direct sysfs write
      # (no brightnessctl dep) only fires when the value actually
      # differs. TTY-side numlock toggles get re-converged to the
      # session state within one tick — accepted, this box has no
      # console workflow.
      systemd.timers.keyd-numlock-sync = {
        wantedBy = ["timers.target"];

        timerConfig = {
          OnBootSec = "10s";
          OnUnitActiveSec = "30s";
          AccuracySec = "5s";
          Unit = "keyd-numlock-sync.service";
        };
      };

      systemd.services.keyd-numlock-sync = {
        description = "Mirror numlock LED from keyd virtual keyboard to physical keyboards";
        wantedBy = [];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${keyd-numlock-sync}/bin/keyd-numlock-sync";
        };
      };

      # Resume: hardware LEDs reset while the uinput virtual device
      # keeps its state, so re-mirror immediately instead of waiting for
      # the next timer tick.
      powerManagement.resumeCommands = ''
        ${keyd-numlock-sync}/bin/keyd-numlock-sync || true
      '';
    };
  };
}
