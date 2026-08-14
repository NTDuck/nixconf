{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {pkgs, ...}: let
      legionPkg = pkgs.unstable.lenovo-legion;

      fanControlScript = pkgs.writeShellScriptBin "legion-fan-auto" ''
        set -euo pipefail

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

          local fan_fullspeed=""
          for f in /sys/module/legion_laptop/drivers/platform:legion/*/fan_fullspeed; do
            if [ -f "$f" ]; then
              fan_fullspeed="$f"
              break
            fi
          done

          if [ "$is_ac" -eq 1 ] && [ "$profile" = "performance" ]; then
            if [ -n "$fan_fullspeed" ]; then
              echo 1 > "$fan_fullspeed" 2>/dev/null || true
            fi
            ${legionPkg}/bin/legion_cli maximumfanspeed enable 2>/dev/null || true
          else
            if [ -n "$fan_fullspeed" ]; then
              echo 0 > "$fan_fullspeed" 2>/dev/null || true
            fi
            ${legionPkg}/bin/legion_cli maximumfanspeed disable 2>/dev/null || true
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
        - fan1_speed: 5500
          fan2_speed: 5500
          cpu_lower_temp: 0
          cpu_upper_temp: 127
          gpu_lower_temp: 0
          gpu_upper_temp: 127
          ic_lower_temp: 0
          ic_upper_temp: 127
          acceleration: 1
          deceleration: 1
        - fan1_speed: 5500
          fan2_speed: 5500
          cpu_lower_temp: 0
          cpu_upper_temp: 127
          gpu_lower_temp: 0
          gpu_upper_temp: 127
          ic_lower_temp: 0
          ic_upper_temp: 127
          acceleration: 1
          deceleration: 1
        - fan1_speed: 5500
          fan2_speed: 5500
          cpu_lower_temp: 0
          cpu_upper_temp: 127
          gpu_lower_temp: 0
          gpu_upper_temp: 127
          ic_lower_temp: 0
          ic_upper_temp: 127
          acceleration: 1
          deceleration: 1
        - fan1_speed: 5500
          fan2_speed: 5500
          cpu_lower_temp: 0
          cpu_upper_temp: 127
          gpu_lower_temp: 0
          gpu_upper_temp: 127
          ic_lower_temp: 0
          ic_upper_temp: 127
          acceleration: 1
          deceleration: 1
        - fan1_speed: 5500
          fan2_speed: 5500
          cpu_lower_temp: 0
          cpu_upper_temp: 127
          gpu_lower_temp: 0
          gpu_upper_temp: 127
          ic_lower_temp: 0
          ic_upper_temp: 127
          acceleration: 1
          deceleration: 1
        - fan1_speed: 5500
          fan2_speed: 5500
          cpu_lower_temp: 0
          cpu_upper_temp: 127
          gpu_lower_temp: 0
          gpu_upper_temp: 127
          ic_lower_temp: 0
          ic_upper_temp: 127
          acceleration: 1
          deceleration: 1
        - fan1_speed: 5500
          fan2_speed: 5500
          cpu_lower_temp: 0
          cpu_upper_temp: 127
          gpu_lower_temp: 0
          gpu_upper_temp: 127
          ic_lower_temp: 0
          ic_upper_temp: 127
          acceleration: 1
          deceleration: 1
        - fan1_speed: 5500
          fan2_speed: 5500
          cpu_lower_temp: 0
          cpu_upper_temp: 127
          gpu_lower_temp: 0
          gpu_upper_temp: 127
          ic_lower_temp: 0
          ic_upper_temp: 127
          acceleration: 1
          deceleration: 1
        - fan1_speed: 5500
          fan2_speed: 5500
          cpu_lower_temp: 0
          cpu_upper_temp: 127
          gpu_lower_temp: 0
          gpu_upper_temp: 127
          ic_lower_temp: 0
          ic_upper_temp: 127
          acceleration: 1
          deceleration: 1
        - fan1_speed: 5500
          fan2_speed: 5500
          cpu_lower_temp: 0
          cpu_upper_temp: 127
          gpu_lower_temp: 0
          gpu_upper_temp: 127
          ic_lower_temp: 0
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
        description = "Lenovo Legion Automatic Max Fan Speed Control (Performance + AC)";
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
