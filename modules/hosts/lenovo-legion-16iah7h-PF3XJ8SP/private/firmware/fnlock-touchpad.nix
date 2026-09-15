{...}: {
  # FnLock (Fn+Esc indicator light) gates the touchpad:
  #   FnLock LED on  -> touchpad enabled
  #   FnLock LED off -> touchpad disabled (mango `disable_trackpad`)
  # FnLock presses emit a GameZone WMI event that legion_laptop forwards as a
  # `platform-profile change` uevent on
  # /devices/platform/legion/platform-profile/platform-profile-0. That uevent
  # is a GENERIC hook — Fn+Q and power-profile writes fire it too — so the
  # handler reads the actual FnLock state and applies idempotently instead of
  # toggling per event. FnLock state is ACPI HALS (bit 0x400); legion_laptop
  # 0.0.22 hides fn_lock on J2CN (model_v0 has no FnLock ACPI path override),
  # so the reader goes through acpi_call's /proc/acpi/call with the VPC0 FQN
  # used by this EC family (\\_SB.PCI0.LPC0.EC0.VPC0.* per model_v0).
  # Trackpad state lives in mango: the script pokes every session's mango IPC
  # socket with `dispatch setoption,disable_trackpad,<0|1>` (absolute state —
  # repeat events no-op). No mango socket (other sessions) -> no-op.
  # NOTE: no boot-time sync — if the EC held FnLock=off across a reboot, the
  # first FnLock press after login re-syncs (mango defaults to trackpad on).
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      config,
      pkgs,
      ...
    }: let
      fnlock-touchpad = pkgs.writeShellScriptBin "fnlock-touchpad" ''
        set -u
        # FnLock state: 1 = LED on (touchpad enabled), 0 = off (disabled).
        printf '%s' '\_SB.PCI0.LPC0.EC0.VPC0.HALS' > /proc/acpi/call || {
          echo "fnlock-touchpad: acpi_call module not loaded" >&2
          exit 1
        }
        val=$(cat /proc/acpi/call)
        case "$val" in
          0x*) ;;
          *) echo "fnlock-touchpad: HALS eval failed: $val" >&2; exit 1 ;;
        esac
        state=$(( (val & 0x0400) != 0 ? 1 : 0 ))

        # Absolute state via setoption: burst/coalesced repeats are no-ops.
        for sock in /run/user/*/mango-*.sock; do
          [ -S "$sock" ] || continue
          printf 'dispatch setoption,disable_trackpad,%s\n' "$((1 - state))" \
            | ${pkgs.netcat-openbsd}/bin/nc -U -N -w 2 "$sock" >/dev/null 2>&1 \
            || echo "fnlock-touchpad: mango IPC failed ($sock)" >&2
        done
      '';
    in {
      # acpi_call lets the sync read FnLock state (HALS) that legion_laptop
      # does not expose via sysfs on this model.
      boot.extraModulePackages = [
        config.boot.kernelPackages.lenovo-legion-module
        config.boot.kernelPackages.acpi_call
      ];
      boot.kernelModules = ["legion_laptop" "acpi_call"];

      # SYSTEMD_WANTS (not udev RUN): non-blocking, queued, coalesced — a slow
      # or failed run cannot stall uevent processing.
      services.udev.extraRules = ''
        ACTION=="change", SUBSYSTEM=="platform-profile", DEVPATH=="*/legion/platform-profile/*", TAG+="systemd", ENV{SYSTEMD_WANTS}="fnlock-touchpad.service"
      '';

      systemd.services.fnlock-touchpad = {
        description = "Sync mango trackpad state to FnLock LED state";
        # udev-triggered units run outside normal target transactions.
        unitConfig.DefaultDependencies = "no";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${fnlock-touchpad}/bin/fnlock-touchpad";
        };
      };
    };
  };
}
