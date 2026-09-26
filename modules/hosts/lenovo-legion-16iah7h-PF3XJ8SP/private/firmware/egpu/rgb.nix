# Toggle for the eGPU 3090's RGB (ASUS ROG STRIX ENE SMBus controller).
#
# The controller hangs off the tunneled card's i2c bus, so its availability
# is coupled to the USB4 tunnel (lives in the homelab specialisation with the
# rest of the eGPU stack). The OpenRGB
# SDK server scans i2c adapters ONCE at startup — which races the tunnel
# bring-up — so "card present but not enumerated" is the steady state right
# after docking; the fix is a server restart, gated to only fire when the
# 3090 is actually unenumerated (an unconditional restart on every USB4
# rebind would tear down keyboard + laptop lighting for seconds each time).
{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      config,
      pkgs,
      ...
    }: let
      openrgb = pkgs.unstable.openrgb;
      # Same package the openrgb aspect runs as server: client/server SDK
      # protocol must match (and must keep matching the running server
      # until the next switch flips it to 1.0).
      og = "${openrgb}/bin/openrgb";
      coreutils = pkgs.coreutils;
      grep = "${pkgs.gnugrep}/bin/grep";
      # -d accepts the controller NAME (verified live: `openrgb -d "ASUS ROG
      # STRIX ..." -m off` rc=0). Indices shift as controllers enumerate
      # (HID keyboards, laptop, eGPU); the ENE device name is stable.
      devName = "ASUS ROG STRIX GeForce RTX 3090 Gaming White OC";
      pciPath = "/sys/bus/pci/devices/0000:06:00.0";
      # openrgb 1.0 dropped the per-device detail block (Modes:/Zones:/LEDs:)
      # from `--list-devices` — verified live against both an rc3.1 server
      # and a 1.0 server; only "N: name" lines are printed. There is no CLI
      # state read left, so toggle keeps its own state file instead of
      # reading the card. 'on' matches firmware-restore: the card lights up
      # on its own when the tunnel comes up, so a missing file means "on".
      # State lives in ayin's XDG state home: egpu-rgb runs unprivileged and
      # a root-owned /var/lib path would kill set_state under set -e; the
      # root-side rescan only READS this file to re-apply a saved "off".
      setOnArgs = "-m static -c FFFFFF";
      # Host-private module (uid 1000 ayin, /home/ayin static): state file
      # path is hardcoded rather than resolved via getent (glibc.bin no
      # longer ships getent on 26.05; the SUDO_USER dance bought nothing).
      stateFile = "/home/ayin/.local/state/egpu-rgb/state";

      egpu-rgb = pkgs.writeShellScriptBin "egpu-rgb" ''
        set -eu
        dev="${devName}"
        state=${stateFile}
        enumerated() {
          ${og} --list-devices 2>/dev/null | ${grep} -q "RTX 3090"
        }
        apply() {
          ${og} -d "$dev" "$@" >/dev/null 2>&1
        }
        rescan() {
          # Root skips polkit; a user session hits the scoped manage-units
          # rule below (systemctl talks to PID1 over the system bus — no
          # pkexec, so no generic exec-path bypass).
          ${config.systemd.package}/bin/systemctl restart openrgb.service
        }
        ensure() {
          enumerated && return 0
          if [ -e ${pciPath} ]; then
            # Card tunneled but server scan is stale (started before the
            # tunnel): one restart re-enumerates.
            rescan
            sleep 2
            enumerated && return 0
            echo "egpu-rgb: 3090 on PCI but OpenRGB still does not list it (nvidia bind pending? retry in a few seconds)" >&2
            exit 1
          fi
          echo "egpu-rgb: 3090 not present (dock detached or USB4 tunnel down)" >&2
          exit 1
        }
        is_on() {
          # No file = card firmware default (lights up with the tunnel) = on.
          [ ! -e "$state" ] || [ "$(${coreutils}/bin/cat "$state")" = "on" ]
        }
        set_state() {
          ${coreutils}/bin/mkdir -p "$(dirname "$state")"
          ${coreutils}/bin/echo "$1" > "$state"
        }
        on() {
          apply ${setOnArgs} || { echo "egpu-rgb: failed to set mode (server restarting? retry)" >&2; exit 1; }
          set_state on
          echo "egpu-rgb: 3090 RGB on (static white)"
        }
        off() {
          apply -m off || { echo "egpu-rgb: failed to set mode (server restarting? retry)" >&2; exit 1; }
          set_state off
          echo "egpu-rgb: 3090 RGB off"
        }

        case ''${1:-toggle} in
          on) ensure; on ;;
          off) ensure; off ;;
          toggle)
            ensure
            if is_on; then off; else on; fi
            ;;
          status)
            ensure
            if is_on; then echo "egpu-rgb: 3090 RGB on (static white)"; else echo "egpu-rgb: 3090 RGB off"; fi
            ;;
          *) echo "usage: egpu-rgb [on|off|toggle|status]" >&2; exit 2 ;;
        esac
      '';

      egpu-rgb-rescan = pkgs.writeShellScriptBin "egpu-rgb-rescan" ''
        set -eu
        # Fired on USB4 tunnel events + at boot. Restart ONLY when the card
        # is on PCI AND unenumerated — every rebind fires change events and
        # an unconditional restart tears down keyboard/laptop lighting.
        # (The server never hot-detects: verified live, the card stays
        # absent from --list-devices until a restart.)
        [ -e ${pciPath} ] || exit 0

        # Bounded window for the nvidia bind (which creates the i2c adapters
        # the server scans); each check is one client round-trip.
        enumerated() {
          ${og} --list-devices 2>/dev/null | ${grep} -q "RTX 3090"
        }
        for _ in $(${coreutils}/bin/seq 1 8); do
          enumerated && found=1 && break
          ${coreutils}/bin/sleep 2
        done
        if [ ''${found:-0} -eq 0 ]; then
          ${config.systemd.package}/bin/systemctl restart openrgb.service
          sleep 2
          enumerated || { echo "egpu-rgb-rescan: 3090 on PCI but not enumerated even after restart" >&2; exit 1; }
          echo "egpu-rgb-rescan: 3090 enumerated after openrgb restart" >&2
        fi

        # Freshly-tunneled card = firmware RGB default (on). Re-apply the
        # user's saved "off" preference (root only reads the state file).
        if [ -f "${stateFile}" ] \
          && [ "$(${coreutils}/bin/cat "${stateFile}")" = "off" ]; then
          ${og} -d "${devName}" -m off >/dev/null 2>&1 || true
          echo "egpu-rgb-rescan: re-applied saved RGB 'off' after enumeration" >&2
        fi
      '';
    in {
      specialisation.homelab.configuration = {
        # HOMELAB-ONLY (2026-09-21 user request, 3090 specialisation pattern): the
        # 3090's i2c RGB controller hangs off the tunneled card — no tunnel,
        # no controller. Lives inside specialisation.homelab with the rest of
        # the eGPU stack.
        environment.systemPackages = [egpu-rgb egpu-rgb-rescan];

        # Passwordless rescan for the user script's ensure() fallback: scoped
        # to the single unit on the manage-units action (NOT pkexec's generic
        # exec action — that matches on the binary path and would allow any
        # `pkexec systemctl ...`).
        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id === "org.freedesktop.systemd1.manage-units" &&
                action.lookup("unit") === "openrgb.service" &&
                subject.local && subject.active) {
              return polkit.Result.YES;
            }
          });
        '';

        # Runtime dock events (the adopt/release machinery these rules
        # originally accompanied was removed 2026-09-21 with the Bonsai
        # stack; the rescan rules stay). '+=' is load-bearing: a plain '='
        # here would REPLACE any SYSTEMD_WANTS set by a later rule on the
        # same event.
        services.udev.extraRules = ''
          ACTION!="remove", SUBSYSTEM=="thunderbolt", ATTRS{device_name}=="UT4G", TAG+="systemd", ENV{SYSTEMD_WANTS}+="egpu-rgb-rescan.service"
          ACTION!="remove", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", ENV{PCI_SLOT_NAME}=="0000:06:00.0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="egpu-rgb-rescan.service"
        '';

        systemd.services.egpu-rgb-rescan = {
          description = "Re-enumerate the eGPU 3090 in OpenRGB after USB4 tunnel bring-up";
          after = ["openrgb.service"];
          # udev-triggered units run outside normal target transactions.
          unitConfig.DefaultDependencies = "no";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${egpu-rgb-rescan}/bin/egpu-rgb-rescan";
            TimeoutStartSec = "60";
          };
        };

        # Boot-time trigger as a timer (never part of a target transaction,
        # so it cannot stall the boot). Covers dock-attached-at-power-on,
        # where the tunneled PCI device appears before this generation's
        # udev rules are loaded and the uevent is never replayed.
        systemd.timers.egpu-rgb-rescan = {
          wantedBy = ["timers.target"];
          timerConfig = {
            OnBootSec = "15";
            Unit = "egpu-rgb-rescan.service";
          };
        };
      }; # specialisation.homelab.configuration
    };
  };
}
