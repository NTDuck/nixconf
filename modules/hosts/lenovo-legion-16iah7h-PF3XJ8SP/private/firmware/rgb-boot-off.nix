# Boot-time RGB blackout (2026-09-26 user request): on startup the ASUS
# 3090 (if connected), the Keychron keyboard (user: "cmk87" — the only
# external keyboard on USB, Keychron Link-KM), and the laptop's builtin
# keyboard (OpenRGB "Lenovo 5 2022" — the 16IAH7H's internal EC
# controller, DMI LNVNB161216) must come up with lights OFF.
#
# Design notes:
#   - Runs as ayin (unprivileged): the openrgb client only talks to the
#     SDK server on localhost:6742 (mode-sets verified live as uid 1000),
#     and the 3090 branch writes the SAME state file the `egpu-rgb`
#     toggle owns (/home/ayin/.local/state/egpu-rgb/state) — root-owned
#     writes there would break the user toggle's set_state under set -e.
#   - Boot-only, NO periodic re-apply: a repeat timer would switch the
#     lights back off minutes after the user turns them on. Late
#     enumeration is covered by recording state=off: homelab's
#     egpu-rgb-rescan re-applies a saved "off" whenever the tunneled
#     card enumerates (see egpu/rgb.nix).
#   - Device identity: controller names are extracted from
#     --list-devices by stable substring (RTX 3090 / Keychron /
#     "Lenovo 5"), not hardcoded verbatim — `openrgb -d` needs the exact
#     controller name, indices shift between boots, and the Keychron
#     name's trailing digit is dongle-slot-dependent.
#   - Any single failure must not block the others: set -u only, never
#     -e; every mode-set checked individually.
{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {pkgs, ...}: let
      openrgb = pkgs.unstable.openrgb;
      # Same package family the openrgb aspect runs as server (client and
      # server SDK protocol must match); CLI mode-sets need no Qt env.
      stateFile = "/home/ayin/.local/state/egpu-rgb/state";
      pciPath = "/sys/bus/pci/devices/0000:06:00.0";

      rgb-boot-off = pkgs.writeShellScriptBin "rgb-boot-off" ''
        set -u
        og="${openrgb}/bin/openrgb"
        state=${stateFile}

        # Bounded enumeration wait: the server scans i2c/USB ONCE at
        # startup and dock/hub devices trail it. One client round-trip
        # per check.
        list=""
        for _ in $(seq 1 9); do
          list="$($og --list-devices 2>/dev/null || true)"
          if echo "$list" | grep -q "RTX 3090" \
            && echo "$list" | grep -q "Keychron" \
            && echo "$list" | grep -q "Lenovo 5"; then
            break
          fi
          sleep 5
        done

        # First controller whose name contains the fragment (exact-name
        # match is what -d requires; indices shift, suffix digits drift).
        extract() {
          echo "$list" | sed -n 's/^[0-9]*: //p' | grep -i -- "$1" | head -1
        }

        off() {
          # "Lenovo 5 2022" (16IAH7H EC controller) has NO off mode
          # (verified live 2026-09-26: "Mode 'off' not available") — fall
          # back to direct all-black, which the same run accepts.
          [ -n "$1" ] || return 0
          $og -d "$1" -m off >/dev/null 2>&1 && return 0
          $og -d "$1" -m direct -c 000000 >/dev/null 2>&1
        }

        record_off() {
          mkdir -p "$(dirname "$state")"
          echo off > "$state"
        }

        # --- Keychron ("cmk87") + laptop builtin keyboard ---
        for frag in Keychron "Lenovo 5"; do
          name="$(extract "$frag")"
          if [ -n "$name" ]; then
            if off "$name"; then
              echo "rgb-boot-off: $name -> off"
            else
              echo "rgb-boot-off: FAILED to turn off $name" >&2
            fi
          else
            echo "rgb-boot-off: no '$frag' controller enumerated; skipping" >&2
          fi
        done

        # --- eGPU 3090 (if connected) ---
        name="$(extract "RTX 3090")"
        if [ -n "$name" ]; then
          if off "$name"; then
            # Keep the egpu-rgb toggle/rescan state in sync: the light is
            # now off, so the next toggle means "on".
            record_off
            echo "rgb-boot-off: $name -> off"
          else
            echo "rgb-boot-off: FAILED to turn off $name" >&2
          fi
        elif [ -e ${pciPath} ]; then
          # Tunneled but not yet enumerable (server scan raced the nvidia
          # bind): record the boot preference — egpu-rgb-rescan re-applies
          # "off" when the card appears.
          record_off
          echo "rgb-boot-off: 3090 on PCI but unenumerated; state=off recorded for rescan" >&2
        fi
      '';
    in {
      environment.systemPackages = [rgb-boot-off];

      # Timer trigger (never part of a target transaction, so it cannot
      # stall the boot; same pattern as egpu-rgb-rescan).
      systemd.services.rgb-boot-off = {
        description = "Turn RGB off on the 3090 (if present), Keychron, and laptop keyboards at boot";
        after = ["openrgb.service"];
        serviceConfig = {
          Type = "oneshot";
          User = "ayin";
          ExecStart = "${rgb-boot-off}/bin/rgb-boot-off";
          TimeoutStartSec = "180";
        };
      };
      systemd.timers.rgb-boot-off = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "15";
          Unit = "rgb-boot-off.service";
        };
      };
    };
  };
}
