# llano V12 Ultra cooling pad on host lenovo-legion-16iah7h-PF3XJ8SP (2026-10-06).
#
# Hardware: Holtek USB-HID 374a:b101 (Myth.Cool protocol, RE'd upstream in
# Quahuay/llano-v12ultra-ctrl). Control = raw HIDIOCGFEATURE/HIDIOCSFEATURE
# ioctls on /dev/hidraw*; all control + telemetry in one 9-byte feature report.
#
# Design decisions:
#   - Fan curve + RGB thresholds live in the tool's own config; the fan-curve
#     daemon is the actual deliverable, CLI power/state calls work out of the
#     box (status reads are safe to run alongside the daemon).
#   - Hotplug lifecycle: upstream cmd_auto opens the hidraw fd ONCE and never
#     reopens — on unplug it catches OSError per cycle and loops forever on
#     the dead fd, so a replug alone would never revive it. The unit is
#     therefore bound to a stable device alias: udev tags the hidraw device
#     into systemd with SYSTEMD_ALIAS=/dev/llano (plus SYMLINK) and a
#     SYSTEMD_WANTS pull-in; bindsTo stops the daemon the moment the device
#     unit vanishes, and the next add event starts a fresh process. No
#     wantedBy: with bindsTo a boot-time start would fail while the pad is
#     absent; udev coldplug emits add events for boot-present devices, so
#     first-plug-at-boot is covered too (same pattern as egpu rgb-rescan).
#   - The daemon runs as root (system-level): it reads hwmon and holds the
#     device across user sessions. Concurrent WRITERS must not race it
#     (PROTOCOL.md: a light command carries the fan speed in byte1 — a second
#     light-writer would stomp the fan); the desktop user interacts via
#     `sudo llano-v12ultra-ctrl light ...` or systemctl on the daemon.
#     Status reads are safe alongside it.
#   - Node access: MODE 0660 group llano (no plugdev on NixOS) + TAG uaccess
#     for logged-in seat users; ayin added to the group directly.
{
  den,
  inputs,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: let
      # Source-only flake input pinned to the v0.1.4 tag commit — see the
      # comment block in flake.nix inputs. buildPythonApplication (not
      # -Package): it ships console scripts. Linux path is pure-stdlib raw
      # hidraw ioctls; plyer is the only runtime dep (fan-reminder
      # notifications). Windows-only deps (wmi, hid) stay out of the Linux
      # closure via upstream's sys_platform markers. The PyQt6 GUI extra is
      # deliberately not built.
      llano-cli = pkgs.python3Packages.buildPythonApplication {
        pname = "llano-v12ultra-ctrl";
        version = "0.1.4";
        pyproject = true;
        src = inputs.llano-v12ultra-ctrl;
        build-system = [pkgs.python3Packages.setuptools];
        dependencies = [pkgs.python3Packages.plyer];
        doCheck = false; # no tests upstream; exercised via the smoke gate
        dontUsePythonImportCheck = true; # GUI extra (PyQt6) deliberately not packaged
        meta = {
          description = "Native Linux control for the llano V12 Ultra USB-HID cooling pad (CLI)";
          homepage = "https://github.com/Quahuay/llano-v12ultra-ctrl";
          license = lib.licenses.mit;
          mainProgram = "llano-v12ultra-ctrl";
        };
      };
      fanCurve = {
        enabled = true;
        # raw 1..100 ≈ 300..2800 RPM (~25 RPM/step, upstream-verified scale)
        points = [
          {
            temp_c = 30;
            raw = 1;
          }
          {
            temp_c = 50;
            raw = 30;
          }
          {
            temp_c = 70;
            raw = 60;
          }
          {
            temp_c = 85;
            raw = 100;
          }
        ];
        min_change_raw = 3;
      };
      pointsToml = builtins.concatStringsSep "\n" (map (p: ''
        [[auto.fan_curve.points]]
        temp_c = ${toString p.temp_c}
        raw = ${toString p.raw}
      '') fanCurve.points);
      configToml = ''
        # Managed by nixconf — edit via modules/hosts/lenovo-legion-16iah7h-PF3XJ8SP/firmware/llano.nix
        [general]
        update_check = false

        [auto]
        poll_interval_s = 5
        hysteresis_c = 3

        [[auto.thresholds]]
        temp_c = 0
        color = 2 # green = cool

        [[auto.thresholds]]
        temp_c = 55
        color = 4 # orange = warm

        [[auto.thresholds]]
        temp_c = 70
        color = 0 # red = hot

        [[auto.thresholds]]
        temp_c = 85
        color = 0
        effect = 3 # chase = visibly critical

        [auto.gpu_alert]
        enabled = true
        temp_c = 87
        hysteresis_c = 5
        color = 3 # purple
        effect = 1 # breathing
        speed = 0

        [auto.fan_curve]
        enabled = ${if fanCurve.enabled then "true" else "false"}
        min_change_raw = ${toString fanCurve.min_change_raw}

        ${pointsToml}
      '';
      udevRules = ''
        # llano V12 Ultra cooling pad (Holtek, Myth.Cool protocol): node access.
        SUBSYSTEM=="usb", ATTR{idVendor}=="374a", ATTR{idProduct}=="b101", MODE="0660", GROUP="llano", TAG+="uaccess"
        KERNEL=="hidraw*", ATTRS{idVendor}=="374a", ATTRS{idProduct}=="b101", MODE="0660", GROUP="llano", TAG+="uaccess", SYMLINK+="llano", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/llano", ENV{SYSTEMD_WANTS}+="llano-v12ultra-ctrl.service"
      '';
    in {
      users.groups.llano = {};

      services.udev.extraRules = udevRules;

      environment.etc."llano-v12ultra-ctrl/config.toml".source =
        builtins.toFile "llano-v12ultra-ctrl-config.toml" configToml;

      systemd.services.llano-v12ultra-ctrl = {
        description = "llano V12 Ultra cooling pad: temperature-linked fan curve + RGB";
        # udev-triggered unit; started only via the device's SYSTEMD_WANTS.
        unitConfig.DefaultDependencies = "no";
        after = ["systemd-udevd.service" "dev-llano.device"];
        # Stop the daemon when the pad disappears (cmd_auto never reopens its
        # hidraw fd); udev SYSTEMD_WANTS restarts it on the next plug.
        bindsTo = ["dev-llano.device"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${llano-cli}/bin/llano-v12ultra-ctrl auto --config /etc/llano-v12ultra-ctrl/config.toml";
          Restart = "on-failure";
          RestartSec = 2;
          # Device-not-found exits rc=2 (main() SystemExit); don't respawn a
          # tight failure loop if the device vanished in the start race.
          RestartPreventExitStatus = 2;
          # Daemon needs: the hidraw node (rw), /sys/class/hwmon reads,
          # nvidia-smi subprocess for the GPU alert. No other writes.
          NoNewPrivileges = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          DeviceAllow = "char-hidraw rw";
        };
      };

      # ayin needs the group only when poking the node directly (status reads
      # alongside the root daemon; uaccess already covers the active seat).
      users.users.ayin.extraGroups = ["llano"];
    };
  };
}
