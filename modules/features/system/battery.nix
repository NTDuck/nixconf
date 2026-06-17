{den, ...}: {
  den.aspects.battery = {
    nixos = {
      services.tlp = {
        enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

          CPU_BOOST_ON_BAT = 0;
          CPU_MAX_PERF_ON_BAT = 60;

          PLATFORM_PROFILE_ON_BAT = "low-power";
          RUNTIME_PM_ON_BAT = "auto";
          PCIE_ASPM_ON_BAT = "powersupersave";

          WIFI_PWR_ON_BAT = "on";

          SOUND_POWER_SAVE_ON_AC = 0;
          SOUND_POWER_SAVE_ON_BAT = 1;
          SOUND_POWER_SAVE_CONTROLLER = "Y";

          SATA_LINKPWR_ON_BAT = "min_power";
        };
      };

      services.fstrim.enable = true;
      services.thermald.enable = true;
      services.throttled.enable = true;
      powerManagement.powertop.enable = true;

      boot.kernelParams = ["nmi_watchdog=0"];

      services.power-profiles-daemon.enable = false;
    };
  };
}
