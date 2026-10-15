# Qt 6.11 + qt5ct QProxyStyle recursion SIGSEGVs every Qt app that
# inherits stylix's QT_QPA_PLATFORMTHEME=qt5ct (legion_gui: lll.nix
# 2026-09-15; OpenRGB GUI coredumps 2026-09-12..19, crash in
# libQt6Core.so.6.11.2 — CLI mode-sets are unaffected, they never build
# widgets). The GUI must launch with the var dropped; the package is
# wrapped wholesale because the NixOS openrgb module feeds `package` to
# BOTH the server unit and environment.systemPackages — a second,
# parallel wrapper derivation would collide with the module's own
# systemPackages entry in the buildEnv (bin/openrgb twice).
{den, ...}: {
  den.aspects.system.hardware.openrgb = {
    nixos = {
      config,
      pkgs,
      ...
    }: let
      openrgb = pkgs.unstable.openrgb;
      openrgb-wrapped = pkgs.stdenvNoCC.mkDerivation {
        name = "openrgb-wrapped";
        meta.mainProgram = "openrgb";
        nativeBuildInputs = [pkgs.makeBinaryWrapper];
        buildCommand = ''
          # Wrap the nixpkgs shim (not the inner .openrgb-wrapped) so the
          # qtHook env (QT_PLUGIN_PATH, XDG_DATA_DIRS) still applies; the
          # shim's exec inherits the --unset below.
          makeWrapper ${openrgb}/bin/openrgb \
            $out/bin/openrgb --unset QT_QPA_PLATFORMTHEME
          # Real dir of per-entry symlinks, not a parent symlink: a
          # dangling share/* symlink breaks the buildEnv ("not a
          # directory", see lll.nix).
          mkdir -p $out/share
          for entry in ${openrgb}/share/*; do
            ln -s "$entry" "$out/share/$(basename "$entry")"
          done
        '';
      };

      # Light switching helpers moved from legion private firmware/egpu/rgb.nix
      # (2026-10-15: unified into openrgb feature for cohesion).
      og = "${openrgb}/bin/openrgb";
      coreutils = pkgs.coreutils;
      grep = "${pkgs.gnugrep}/bin/grep";
      devName = "ASUS ROG STRIX GeForce RTX 3090 Gaming White OC";
      pciPath = "/sys/bus/pci/devices/0000:06:00.0";
      setOnArgs = "-m static -c FFFFFF";
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

        # Card enumerated: ensure startup profile is applied
        # (2026-10-15: replaced saved 'off' re-apply with static-rainbow profile load).
        ${og} --profile lenovo-legion-16iah7h-PF3XJ8SP-static-rainbow >/dev/null 2>&1 || true
        echo "egpu-rgb-rescan: applied lenovo-legion-16iah7h-PF3XJ8SP-static-rainbow profile after enumeration" >&2
      '';
    in {
      services.hardware.openrgb = {
        enable = true;
        package = openrgb-wrapped;
        # 2026-10-15: Automatically apply static rainbow profile at startup
        # across Lenovo Legion keyboard, Keychron, and eGPU 3090.
        startupProfile = "lenovo-legion-16iah7h-PF3XJ8SP-static-rainbow";
      };

      specialisation.homelab.configuration = {
        # HOMELAB-ONLY (3090 specialisation pattern): the 3090's i2c RGB controller
        # hangs off the tunneled card — no tunnel, no controller.
        environment.systemPackages = [egpu-rgb egpu-rgb-rescan];

        # Passwordless rescan for the user script's ensure() fallback: scoped
        # to the single unit on the manage-units action.
        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id === "org.freedesktop.systemd1.manage-units" &&
                action.lookup("unit") === "openrgb.service" &&
                subject.local && subject.active) {
              return polkit.Result.YES;
            }
          });
        '';

        services.udev.extraRules = ''
          ACTION!="remove", SUBSYSTEM=="thunderbolt", ATTRS{device_name}=="UT4G", TAG+="systemd", ENV{SYSTEMD_WANTS}+="egpu-rgb-rescan.service"
          ACTION!="remove", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", ENV{PCI_SLOT_NAME}=="0000:06:00.0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="egpu-rgb-rescan.service"
        '';

        systemd.services.egpu-rgb-rescan = {
          description = "Re-enumerate the eGPU 3090 in OpenRGB after USB4 tunnel bring-up";
          after = ["openrgb.service"];
          unitConfig.DefaultDependencies = "no";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${egpu-rgb-rescan}/bin/egpu-rgb-rescan";
            TimeoutStartSec = "60";
          };
        };

        systemd.timers.egpu-rgb-rescan = {
          wantedBy = ["timers.target"];
          timerConfig = {
            OnBootSec = "15";
            Unit = "egpu-rgb-rescan.service";
          };
        };
      };
    };
  };
}
