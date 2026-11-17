# DELL X11 display mirroring — aspect-preserving auto-fit, stretch, and off
# modes for external displays/projectors on spectrwm/X11 (2026-11-17).
#
# Commands provided:
#   - `mirror [fit|stretch|down]` (or `mirror switch [mode]`, default: `fit`)
#   - `hdmi switch [stretch|down|fit]` (alias wrapper)
#   - `mirror-fit` (convenience shortcut for mirror fit)
#
# Modes:
#   1. `fit` (auto-fit): Dynamically reads the projector's preferred EDID mode
#      via xrandr, computes uniform scaling factor s = min(W_proj/1366, H_proj/768),
#      and applies an aspect-preserving xrandr transformation matrix with
#      centered letterboxing/pillarboxing borders.
#   2. `stretch`: Scales the 1366x768 framebuffer across the external mode via
#      xrandr --scale-from 1366x768 (fills entire screen, ignoring aspect ratio).
#   3. `down`: Turns off all external outputs and resets eDP-1.
#
# UDEV:
#   Re-applies `mirror fit` on DRM change events (plug/unplug).
{
  den,
  lib,
  ...
}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    nixos = {pkgs, ...}: let
      mirrorPy = pkgs.writeText "mirror.py" ''
        import os
        import re
        import sys
        import subprocess

        INTERNAL = "eDP-1"
        PANEL_W = 1366
        PANEL_H = 768
        KNOWN_EXTERNALS = ["HDMI-A-1", "HDMI-A-2", "DP-1", "HDMI-1", "HDMI-2", "DP-2"]
        XRANDR = "${pkgs.xrandr}/bin/xrandr"

        def print_help():
            print("""Usage: mirror [MODE]
               mirror switch [MODE]
               hdmi switch [MODE]

        Modes:
          fit       Auto-fit Dell's 1366x768 display onto external projector/monitor,
                    automatically detecting preferred resolution and preserving aspect
                    ratio with letterboxing / pillarboxing (default).
          stretch   Scale Dell's 1366x768 display to fill the entire external screen
                    using --scale-from (stretching if aspect ratio differs).
          down      Turn off all external displays (keep internal eDP-1 active).

        Examples:
          mirror fit            # Auto-fit mirror on connected projector
          mirror stretch        # Stretched mirror
          mirror down           # Turn off HDMI / projector
          hdmi switch fit       # Equivalent alias
          hdmi switch stretch   # Equivalent alias
          hdmi switch down      # Equivalent alias
        """)

        def parse_xrandr(output):
            displays = {}
            current = None
            for line in output.splitlines():
                m = re.match(r"^([A-Za-z0-9-]+)\s+(connected|disconnected)(.*)", line)
                if m:
                    name, status, rest = m.groups()
                    current = name
                    displays[current] = {"status": status, "modes": [], "preferred": None}
                    continue
                if current and displays[current]["status"] == "connected":
                    m_mode = re.match(r"^\s+([0-9]+)x([0-9]+)\s+(.*)", line)
                    if m_mode:
                        w, h, flags = int(m_mode.group(1)), int(m_mode.group(2)), m_mode.group(3)
                        displays[current]["modes"].append((w, h))
                        if "+" in flags and not displays[current]["preferred"]:
                            displays[current]["preferred"] = (w, h)
            for name, info in displays.items():
                if info["status"] == "connected" and not info["preferred"] and info["modes"]:
                    info["preferred"] = info["modes"][0]
            return displays

        def find_outputs(displays):
            internal = None
            for name in [INTERNAL, "eDP-1", "eDP1"]:
                if name in displays and displays[name]["status"] == "connected":
                    internal = name
                    break
            if not internal:
                for name, info in displays.items():
                    if info["status"] == "connected" and (name.startswith("eDP") or name.startswith("LVDS")):
                        internal = name
                        break
            if not internal:
                internal = INTERNAL

            connected_externals = [
                name for name, info in displays.items()
                if info["status"] == "connected" and name != internal
            ]
            disconnected_externals = [
                name for name in set(list(displays.keys()) + KNOWN_EXTERNALS)
                if name != internal and name not in connected_externals
            ]
            return internal, connected_externals, sorted(disconnected_externals)

        def mode_down(internal, connected_externals, disconnected_externals):
            cmd = [
                XRANDR,
                "--output", internal,
                "--auto",
                "--mode", f"{PANEL_W}x{PANEL_H}",
                "--pos", "0x0",
                "--scale", "1x1",
                "--transform", "none"
            ]
            all_externals = set(connected_externals) | set(disconnected_externals)
            for out in sorted(all_externals):
                cmd += ["--output", out, "--off"]
            subprocess.run(cmd, check=True)
            print("External display(s) turned off.")

        def mode_stretch(internal, connected_externals, disconnected_externals):
            if not connected_externals:
                cmd = [
                    XRANDR,
                    "--output", internal,
                    "--auto",
                    "--mode", f"{PANEL_W}x{PANEL_H}",
                    "--pos", "0x0",
                    "--scale", "1x1",
                    "--transform", "none"
                ]
                for out in disconnected_externals:
                    cmd += ["--output", out, "--off"]
                subprocess.run(cmd, check=True)
                print("mirror stretch: no external display connected.", file=sys.stderr)
                return

            cmd = [
                XRANDR,
                "--output", internal,
                "--mode", f"{PANEL_W}x{PANEL_H}",
                "--pos", "0x0",
                "--scale", "1x1",
                "--transform", "none"
            ]
            for out in connected_externals:
                cmd += [
                    "--output", out,
                    "--auto",
                    "--pos", "0x0",
                    "--scale-from", f"{PANEL_W}x{PANEL_H}"
                ]
            for out in disconnected_externals:
                cmd += ["--output", out, "--off"]

            subprocess.run(cmd, check=True)
            for out in connected_externals:
                subprocess.run([XRANDR, "--output", out, "--filter", "bilinear"], capture_output=True)
            print(f"mirror stretch: mirrored {internal} ({PANEL_W}x{PANEL_H}) onto {', '.join(connected_externals)} (stretch).")

        def mode_fit(internal, connected_externals, disconnected_externals, displays):
            if not connected_externals:
                cmd = [
                    XRANDR,
                    "--output", internal,
                    "--auto",
                    "--mode", f"{PANEL_W}x{PANEL_H}",
                    "--pos", "0x0",
                    "--scale", "1x1",
                    "--transform", "none"
                ]
                for out in disconnected_externals:
                    cmd += ["--output", out, "--off"]
                subprocess.run(cmd, check=True)
                print("mirror fit: no external display connected.", file=sys.stderr)
                return

            cmd = [
                XRANDR,
                "--output", internal,
                "--mode", f"{PANEL_W}x{PANEL_H}",
                "--pos", "0x0",
                "--scale", "1x1",
                "--transform", "none"
            ]
            for out in connected_externals:
                info = displays.get(out, {})
                pref = info.get("preferred")
                if not pref:
                    cmd += [
                        "--output", out,
                        "--auto",
                        "--pos", "0x0",
                        "--scale-from", f"{PANEL_W}x{PANEL_H}"
                    ]
                    continue
                Wt, Ht = pref
                s = min(Wt / PANEL_W, Ht / PANEL_H)
                k = 1.0 / s
                w_fit = PANEL_W * s
                h_fit = PANEL_H * s
                dx = (Wt - w_fit) / 2.0
                dy = (Ht - h_fit) / 2.0
                a = k
                c = 0.0 if abs(dx) < 1e-4 else -k * dx
                e = k
                f = 0.0 if abs(dy) < 1e-4 else -k * dy
                transform = f"{a:.8f},0,{c:.4f},0,{e:.8f},{f:.4f},0,0,1"
                cmd += [
                    "--output", out,
                    "--mode", f"{Wt}x{Ht}",
                    "--pos", "0x0",
                    "--transform", transform
                ]
            for out in disconnected_externals:
                cmd += ["--output", out, "--off"]

            subprocess.run(cmd, check=True)
            for out in connected_externals:
                subprocess.run([XRANDR, "--output", out, "--filter", "bilinear"], capture_output=True)
            print(f"mirror fit: mirrored {internal} ({PANEL_W}x{PANEL_H}) onto {', '.join(connected_externals)} (auto-fit).")

        def main():
            args = sys.argv[1:]
            if args and args[0] == "switch":
                args = args[1:]

            mode = args[0].lower() if args else "fit"

            if mode in ("-h", "--help", "help"):
                print_help()
                sys.exit(0)

            if mode not in ("fit", "stretch", "down", "off"):
                print(f"mirror: unknown mode '{mode}'", file=sys.stderr)
                print_help()
                sys.exit(2)

            res = subprocess.run([XRANDR, "--query"], capture_output=True, text=True)
            if res.returncode != 0:
                print(f"mirror: xrandr --query failed: {res.stderr}", file=sys.stderr)
                sys.exit(res.returncode)

            displays = parse_xrandr(res.stdout)
            internal, connected_externals, disconnected_externals = find_outputs(displays)

            if mode in ("down", "off"):
                mode_down(internal, connected_externals, disconnected_externals)
            elif mode == "stretch":
                mode_stretch(internal, connected_externals, disconnected_externals)
            elif mode == "fit":
                mode_fit(internal, connected_externals, disconnected_externals, displays)

        if __name__ == "__main__":
            main()
      '';

      mirror = pkgs.writeShellScriptBin "mirror" ''
        set -u

        if [ "$(id -u)" -eq 0 ]; then
          [ -d /tmp/.X11-unix ] || exit 0
          exec ${pkgs.util-linux}/bin/runuser -u ayin -- env \
            DISPLAY=:0 \
            XAUTHORITY=/home/ayin/.Xauthority \
            ${pkgs.python3}/bin/python3 ${mirrorPy} "$@"
        fi

        DISPLAY="''${DISPLAY:-:0}"
        XAUTHORITY="''${XAUTHORITY:-/home/ayin/.Xauthority}"
        export DISPLAY XAUTHORITY

        [ -d /tmp/.X11-unix ] || {
          echo "mirror: no X server running" >&2
          exit 1
        }

        exec ${pkgs.python3}/bin/python3 ${mirrorPy} "$@"
      '';

      hdmi = pkgs.writeShellScriptBin "hdmi" ''
        exec ${mirror}/bin/mirror "$@"
      '';

      mirrorFit = pkgs.writeShellScriptBin "mirror-fit" ''
        exec ${mirror}/bin/mirror fit "$@"
      '';

      udevMirrorScript = pkgs.writeShellScript "dell-x11-mirror" ''
        set -u
        [ -d /tmp/.X11-unix ] || exit 0
        exec ${mirror}/bin/mirror fit
      '';
    in {
      environment.systemPackages = [
        mirror
        hdmi
        mirrorFit
      ];

      services.udev.extraRules = ''
        SUBSYSTEM=="drm", ACTION=="change", RUN{program}+="${udevMirrorScript}"
      '';
    };
  };
}
