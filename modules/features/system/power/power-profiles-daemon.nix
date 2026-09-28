{den, ...}: {
  den.aspects.system.power.power-profiles-daemon = {
    nixos = {pkgs, ...}: {
      services.power-profiles-daemon = {
        enable = true;
        package = pkgs.unstable.power-profiles-daemon;
      };

      # AC/battery profile switching (2026-09-28): PPD itself never moves
      # off its default profile — desktop environments do that, and the
      # hosts using this aspect run bare WMs (spectrwm/labwc). Policy:
      # maximal resources on AC, minimal on battery. A udev rule on
      # power_supply events re-runs a oneshot that maps mains-online to
      # the `performance` profile and battery to `power-saver`; PPD
      # translates those into intel_pstate EPP + platform_profile
      # (performance vs power/low-power). Boot/AC-add events are covered
      # by ACTION=="add" (coldplug replays them), so the profile is
      # correct from first boot.
      systemd.services.ppd-power-switch = {
        description = "Sync power-profiles-daemon profile to AC/battery state";
        wantedBy = ["multi-user.target"];
        after = ["power-profiles-daemon.service"];
        wants = ["power-profiles-daemon.service"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "ppd-power-switch" ''
            online=0
            for supply in /sys/class/power_supply/A*; do
              if [ -e "$supply/online" ] && [ "$(cat "$supply/online")" = "1" ]; then
                online=1
              fi
            done
            if [ "$online" = 1 ]; then
              exec ${pkgs.unstable.power-profiles-daemon}/bin/powerprofilesctl set performance
            else
              exec ${pkgs.unstable.power-profiles-daemon}/bin/powerprofilesctl set power-saver
            fi
          '';
        };
      };

      services.udev.extraRules = ''
        ACTION=="add|change", SUBSYSTEM=="power_supply", ATTR{online}=="*", ENV{SYSTEMD_WANTS}="ppd-power-switch.service"
      '';
    };
  };
}
