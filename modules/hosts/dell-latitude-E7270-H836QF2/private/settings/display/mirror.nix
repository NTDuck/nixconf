# DELL X11 display mirroring — the spectrwm/X11 equivalent of legion's
# kanshi + wl-mirror stack (2026-09-22).
#
# LEGION REFERENCE (modules/features/desktop/wayland/kanshi.nix): kanshi
# watches for external outputs; on plug it starts wl-mirror@HDMI-*.service
# mirroring eDP-1 onto the external; on unplug it stops the mirrors.
#
# DELL is X11 (spectrwm) — no kanshi (wlr-only), no wl-mirror (wlr-only).
# X11 native mechanism: xrandr --same-as clones the framebuffer onto the
# external output (the projector letterboxes/scales the shared region —
# the same "fit" semantics as wl-mirror --scaling fit).
#
# HOTPLUG WIRING: udev fires "change" on the DRM card device when a
# connector is plugged/unplugged. A root rule runs an idempotent script
# that re-applies the whole state on every event:
#   - every connected external (HDMI-A-1, HDMI-A-2, DP-1) is cloned onto
#     from eDP-1 (laptop panel is the source of truth, like legion);
#   - disconnected externals are turned off;
#   - if no external is present, eDP-1 runs alone.
# Re-running on every event is safe (xrandr calls are idempotent) and
# self-healing (a missed event is repaired by the next one).
#
# X ACCESS: the session is started by greetd+tuigreet as user ayin via
# startx (see the session wrapper in ../../default.nix), so XAUTHORITY
# is $HOME/.Xauthority and DISPLAY=:0 — the script runs xrandr as ayin
# via runuser. Hardcoded single-user host values are fine: this aspect
# is dell-private by construction.
{den, lib, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    nixos = {pkgs, ...}: let
      INTERNAL = "eDP-1";
      EXTERNALS = ["HDMI-A-1" "HDMI-A-2" "DP-1"];

      # Idempotent mirror-state applier. Runs as root from udev, drops to
      # ayin for the xrandr calls.
      mirrorScript = pkgs.writeShellScript "dell-x11-mirror" ''
        set -u

        # No running X server (greeter before login, console-only boot):
        # nothing to configure, exit quietly.
        [ -d /tmp/.X11-unix ] || exit 0

        XRANDR() {
          runuser -u ayin -- env \
            DISPLAY=:0 \
            XAUTHORITY=/home/ayin/.Xauthority \
            ${pkgs.xorg.xrandr}/bin/xrandr "$@"
        }

        xrandr_state=$($XRANDR --query 2>/dev/null) || exit 0

        any_connected=0
        ${lib.concatMapStrings (out: ''
          if echo "$xrandr_state" | grep -q "^${out} connected"; then
            any_connected=1
            # Clone the internal panel onto the external. --auto picks
            # the output's preferred mode; --same-as pins it to (0,0) so
            # both show the same region.
            $XRANDR --output "${out}" --auto --same-as "${INTERNAL}"
          else
            $XRANDR --output "${out}" --off
          fi
        '') EXTERNALS}

        # Ensure the internal panel is on even if it somehow got disabled.
        $XRANDR --output "${INTERNAL}" --auto
      '';
    in {
      services.udev.extraRules = ''
        # X11 hotplug mirror (see header comment): re-apply mirror state on
        # every DRM hotplug event. The script is idempotent.
        SUBSYSTEM=="drm", ACTION=="change", RUN{program}+="${mirrorScript}"
      '';
    };
  };
}
