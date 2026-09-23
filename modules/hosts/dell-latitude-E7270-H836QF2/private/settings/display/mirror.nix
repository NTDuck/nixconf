# DELL X11 display mirroring — the spectrwm/X11 equivalent of legion's
# kanshi mirror profiles (2026-09-23).
#
# LEGION REFERENCE (modules/features/desktop/wayland/kanshi.nix): kanshi
# watches for external outputs; on plug it switches to a mirror profile
# that clones eDP-1 onto the external (compositor-level overlap clone);
# the laptop profile disables the externals on unplug.
#
# DELL is X11 (spectrwm) — no kanshi (wlr-only), no wl-mirror (wlr-only).
# X11 native mechanism: xrandr --same-as clones the framebuffer onto the
# external output (the projector letterboxes/scales the shared region —
# the same "fit" semantics as wl-mirror --scaling fit).
#
# THREE entry points share one xrandr flag set:
#   - `hdmi-up` (user command): clone eDP-1 onto every CONNECTED external.
#   - `hdmi-down` (user command): turn every external off.
#   - the udev hotplug rule: re-applies the whole state on DRM "change"
#     events (plug/unplug without typing commands).
#
# XRANDR FLAG NOTES (validated against xrandr 1.5.4):
#   --auto                 pick the output's preferred mode.
#   --same-as eDP-1        pin the output at eDP-1's position — the two
#                          outputs share the framebuffer region (clone,
#                          NOT a new headless/extended head).
#   --scale-from 1366x768  sample a 1366x768 region regardless of the
#                          output's native mode: a 1080p projector scales
#                          the panel's content up instead of showing a
#                          cropped/extended region. On a 768p projector
#                          it is a no-op. (ChatGPT's proposed command had
#                          this right — but named the output "HDMI-1";
#                          this laptop's connectors are HDMI-A-1,
#                          HDMI-A-2, DP-1 per /sys/class/drm.)
#
# X ACCESS: the session is started by greetd+tuigreet as user ayin via
# startx (see the session wrapper in ../../default.nix), so XAUTHORITY
# is $HOME/.Xauthority and DISPLAY=:0 — root-run paths drop to ayin via
# runuser; the user-facing scripts run as ayin directly. Hardcoded
# single-user host values are fine: this aspect is dell-private.
{
  den,
  lib,
  ...
}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    nixos = {pkgs, ...}: let
      INTERNAL = "eDP-1";
      EXTERNALS = ["HDMI-A-1" "HDMI-A-2" "DP-1"];
      PANEL_MODE = "1366x768";

      # User-facing xrandr environment. The user scripts run inside the
      # spectrwm session (DISPLAY/XAUTHORITY already set); the wrapper
      # keeps them working from SSH/tty too.
      xrandrEnv = ''
        DISPLAY="''${DISPLAY:-:0}"
        XAUTHORITY="''${XAUTHORITY:-/home/ayin/.Xauthority}"
        export DISPLAY XAUTHORITY
      '';

      # Mirror every CONNECTED external; leave disconnected ones off.
      # Shared by hdmi-up and the udev applier.
      mirrorUp = ''
        ${lib.concatMapStrings (out: ''
          if ${pkgs.xorg.xrandr}/bin/xrandr --query | grep -q "^${out} connected"; then
            ${pkgs.xorg.xrandr}/bin/xrandr \
              --output "${out}" --auto --same-as "${INTERNAL}" \
              --scale-from ${PANEL_MODE}
          else
            ${pkgs.xorg.xrandr}/bin/xrandr --output "${out}" --off
          fi
        '') EXTERNALS}
        # The internal panel is the source of truth; make sure it never
        # got disabled by an earlier partial run.
        ${pkgs.xorg.xrandr}/bin/xrandr --output "${INTERNAL}" --auto
      '';

      hdmiUp = pkgs.writeShellScriptBin "hdmi-up" ''
        set -u
        ${xrandrEnv}
        # No running X server: nothing to configure.
        [ -d /tmp/.X11-unix ] || {
          echo "hdmi-up: no X server running" >&2
          exit 1
        }
        ${mirrorUp}
      '';

      hdmiDown = pkgs.writeShellScriptBin "hdmi-down" ''
        set -u
        ${xrandrEnv}
        [ -d /tmp/.X11-unix ] || {
          echo "hdmi-down: no X server running" >&2
          exit 1
        }
        ${lib.concatMapStrings (out: ''
          ${pkgs.xorg.xrandr}/bin/xrandr --output "${out}" --off
        '') EXTERNALS}
      '';

      # Idempotent mirror-state applier for udev hotplug. Runs as root,
      # drops to ayin for the xrandr calls (same flag set as hdmi-up).
      udevMirrorScript = pkgs.writeShellScript "dell-x11-mirror" ''
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

        ${lib.concatMapStrings (out: ''
          if echo "$xrandr_state" | grep -q "^${out} connected"; then
            # Clone the internal panel onto the external (same flags as
            # hdmi-up): preferred mode, pinned at eDP-1's position,
            # sampled from the panel's 1366x768 region.
            $XRANDR --output "${out}" --auto --same-as "${INTERNAL}" \
              --scale-from ${PANEL_MODE}
          else
            $XRANDR --output "${out}" --off
          fi
        '') EXTERNALS}

        # Ensure the internal panel is on even if it somehow got disabled.
        $XRANDR --output "${INTERNAL}" --auto
      '';
    in {
      environment.systemPackages = [
        hdmiUp
        hdmiDown
      ];

      services.udev.extraRules = ''
        # X11 hotplug mirror (see header comment): re-apply mirror state on
        # every DRM hotplug event. The script is idempotent.
        SUBSYSTEM=="drm", ACTION=="change", RUN{program}+="${udevMirrorScript}"
      '';
    };
  };
}
