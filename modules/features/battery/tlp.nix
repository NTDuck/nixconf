{den, ...}: {
  den.aspects.battery.tlp = {
    nixos = {pkgs, ...}: {
      services.tlp = {
        enalble = true;
        package = pkgs.unstable.tlp;

        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;

          CPU_MIN_PERF_ON_AC = 100;
          CPU_MIN_PERF_ON_BAT = 10;

          CPU_MAX_PERF_ON_AC = 100;
          CPU_MAX_PERF_ON_BAT = 60;

          PLATFORM_PROFILE_ON_AC = "performance";
          PLATFORM_PROFILE_ON_BAT = "low-power";

          PCIE_ASPM_ON_AC = "performance";
          PCIE_ASPM_ON_BAT = "powersupersave";

          SATA_LINKPWR_ON_AC = "max_performance";
          SATA_LINKPWR_ON_BAT = "min_power";

          USB_AUTOSUSPEND_ON_AC = 0;
          USB_AUTOSUSPEND_ON_BAT = 1;

          WIFI_PWR_ON_AC = "off";
          WIFI_PWR_ON_BAT = "on";

          SOUND_POWER_SAVE_ON_AC = 0;
          SOUND_POWER_SAVE_ON_BAT = 1;
          SOUND_POWER_SAVE_CONTROLLER = "Y";

          RUNTIME_PM_ON_AC = "on";
          RUNTIME_PM_ON_BAT = "auto";

          BACKLIGHT_ON_AC = 80;
          BACKLIGHT_ON_BAT = 15;

          CPU_HWP_ON_AC = "performance";
          CPU_HWP_ON_BAT = "power";

          SCHED_POWERSAVE_ON_AC = 0;
          SCHED_POWERSAVE_ON_BAT = 1;

          # NMI_WATCHDOG_ON_AC = 0;
          # NMI_WATCHDOG_ON_BAT = 0;
        };
      };
    };
  };
}
