{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {pkgs, ...}: let
      legionPkg = pkgs.unstable.lenovo-legion;

      fanControlScript = pkgs.writeShellScriptBin "legion-fan-auto" ''
        set -euo pipefail

        LAST_STATE=""

        update_fan_speed() {
          local is_ac=0
          for p in /sys/class/power_supply/*; do
            if [ -f "$p/type" ] && [ "$(cat "$p/type" 2>/dev/null)" = "Mains" ] && [ -f "$p/online" ]; then
              if [ "$(cat "$p/online" 2>/dev/null)" = "1" ]; then
                is_ac=1
                break
              fi
            elif [ -f "$p/online" ] && [[ "$(basename "$p")" =~ ^(AC|ADP).* ]]; then
              if [ "$(cat "$p/online" 2>/dev/null)" = "1" ]; then
                is_ac=1
                break
              fi
            fi
          done

          local profile=""
          if [ -f /sys/firmware/acpi/platform_profile ]; then
            profile="$(tr -d '[:space:]' < /sys/firmware/acpi/platform_profile 2>/dev/null || true)"
          fi

          local current_state="ac=''${is_ac}_profile=''${profile}"

          local fan_fullspeed=""
          for f in /sys/module/legion_laptop/drivers/platform:legion/*/fan_fullspeed; do
            if [ -f "$f" ]; then
              fan_fullspeed="$f"
              break
            fi
          done

          if [ -n "$fan_fullspeed" ]; then
            echo 0 > "$fan_fullspeed" 2>/dev/null || true
          fi

          if [ "$current_state" != "$LAST_STATE" ]; then
            LAST_STATE="$current_state"
            if [ "$is_ac" -eq 1 ] && [ "$profile" = "performance" ]; then
              if [ -f /etc/legion_linux/performance-ac.yaml ]; then
                ${legionPkg}/bin/legion_cli fancurve-write-file-to-hw /etc/legion_linux/performance-ac.yaml 2>/dev/null || true
              else
                ${legionPkg}/bin/legion_cli fancurve-write-preset-to-hw performance-ac 2>/dev/null || true
              fi
            else
              ${legionPkg}/bin/legion_cli fancurve-write-preset-for-current-profile 2>/dev/null || true
            fi
          fi
        }

        if [ "''${1:-}" = "--daemon" ]; then
          while true; do
            update_fan_speed
            sleep 3
          done
        else
          update_fan_speed
        fi
      '';

      performanceAcPreset = ''
        name: performance-ac
        enable_minifancurve: false
        entries:
        - fan1_speed: 1800
          fan2_speed: 1800
          cpu_lower_temp: 0
          cpu_upper_temp: 40
          gpu_lower_temp: 0
          gpu_upper_temp: 42
          ic_lower_temp: 0
          ic_upper_temp: 35
          acceleration: 3
          deceleration: 3
        - fan1_speed: 2200
          fan2_speed: 2200
          cpu_lower_temp: 40
          cpu_upper_temp: 50
          gpu_lower_temp: 42
          gpu_upper_temp: 52
          ic_lower_temp: 35
          ic_upper_temp: 40
          acceleration: 3
          deceleration: 3
        - fan1_speed: 2600
          fan2_speed: 2600
          cpu_lower_temp: 50
          cpu_upper_temp: 58
          gpu_lower_temp: 52
          gpu_upper_temp: 60
          ic_lower_temp: 40
          ic_upper_temp: 45
          acceleration: 3
          deceleration: 3
        - fan1_speed: 3000
          fan2_speed: 3000
          cpu_lower_temp: 58
          cpu_upper_temp: 65
          gpu_lower_temp: 60
          gpu_upper_temp: 66
          ic_lower_temp: 45
          ic_upper_temp: 50
          acceleration: 3
          deceleration: 3
        - fan1_speed: 3400
          fan2_speed: 3400
          cpu_lower_temp: 65
          cpu_upper_temp: 72
          gpu_lower_temp: 66
          gpu_upper_temp: 72
          ic_lower_temp: 50
          ic_upper_temp: 55
          acceleration: 2
          deceleration: 2
        - fan1_speed: 3800
          fan2_speed: 3800
          cpu_lower_temp: 72
          cpu_upper_temp: 78
          gpu_lower_temp: 72
          gpu_upper_temp: 78
          ic_lower_temp: 55
          ic_upper_temp: 127
          acceleration: 2
          deceleration: 2
        - fan1_speed: 4100
          fan2_speed: 4100
          cpu_lower_temp: 78
          cpu_upper_temp: 84
          gpu_lower_temp: 78
          gpu_upper_temp: 84
          ic_lower_temp: 127
          ic_upper_temp: 127
          acceleration: 2
          deceleration: 2
        - fan1_speed: 4300
          fan2_speed: 4300
          cpu_lower_temp: 84
          cpu_upper_temp: 90
          gpu_lower_temp: 84
          gpu_upper_temp: 90
          ic_lower_temp: 127
          ic_upper_temp: 127
          acceleration: 1
          deceleration: 1
        - fan1_speed: 4400
          fan2_speed: 4400
          cpu_lower_temp: 90
          cpu_upper_temp: 95
          gpu_lower_temp: 90
          gpu_upper_temp: 95
          ic_lower_temp: 127
          ic_upper_temp: 127
          acceleration: 1
          deceleration: 1
        - fan1_speed: 5500
          fan2_speed: 5500
          cpu_lower_temp: 95
          cpu_upper_temp: 127
          gpu_lower_temp: 95
          gpu_upper_temp: 127
          ic_lower_temp: 127
          ic_upper_temp: 127
          acceleration: 1
          deceleration: 1
      '';
    in {
      environment.systemPackages = [
        legionPkg
        fanControlScript
      ];

      environment.etc."legion_linux/performance-ac.yaml".text = performanceAcPreset;

      services.udev.extraRules = ''
        ACTION=="change", SUBSYSTEM=="power_supply", RUN+="${fanControlScript}/bin/legion-fan-auto"
        ACTION=="change", SUBSYSTEM=="platform", RUN+="${fanControlScript}/bin/legion-fan-auto"
      '';

      systemd.services.legion-fan-control = {
        description = "Lenovo Legion Automatic Fan Curve Control (Performance + AC)";
        after = ["multi-user.target" "power-profiles-daemon.service"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${fanControlScript}/bin/legion-fan-auto --daemon";
          Restart = "always";
          RestartSec = "5s";
        };
      };
    };
  };
}
