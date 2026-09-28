# DELL power-source profile switching — the policy "minimal resource
# usage on battery, maximal on AC" lives HERE, not in the shared
# power-profiles-daemon aspect: that aspect is also pulled transitively
# into LEGION via noctalia's includes (panels/noctalia/default.nix), and
# a udev auto-switcher running there would fight legion_gui's custom
# platform-profile mode (PPD's reassertion reverts custom writes ~2s —
# proven 2026-09-15, see legion host exclusion comment). Legion's power
# policy is "always maximal" and is driven by legion_gui/legion-laptop;
# nothing may rewrite profiles behind its back.
{
  den,
  pkgs,
  ...
}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    nixos = {pkgs, ...}: {
      # PPD never moves off its default profile by itself — profile
      # switching on power-source changes is the desktop environment's
      # job, and DELL runs a bare WM (spectrwm). A udev rule on
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
