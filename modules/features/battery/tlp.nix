{den, ...}: {
  den.aspects.battery.tlp = {
    nixos = {pkgs, ...}: {
      services.tlp = {
        enable = true;
        package = pkgs.unstable.tlp;

        # https://linrunner.de/tlp/
        settings = {
          # Audio
          SOUND_POWER_SAVE_ON_AC = 0;
          SOUND_POWER_SAVE_ON_BAT = 1;
          SOUND_POWER_SAVE_CONTROLLER = "Y";

          # Kernel
          NMI_WATCHDOG = 1;

          # Networking
          WIFI_PWR_ON_AC = "off";
          WIFI_PWR_ON_BAT = "on";

          # Platform
          PLATFORM_PROFILE_ON_AC = "performance";
          PLATFORM_PROFILE_ON_BAT = "low-power";

          MEM_SLEEP_ON_AC = "s2idle";
          MEM_SLEEP_ON_BAT = "deep";

          # Processor
          CPU_DRIVER_OPMODE_ON_AC = "active";
          CPU_DRIVER_OPMODE_ON_BAT = "active";

          CPU_SCALING_GOVERNOR_ON_AC = "performance"; # <- `CPU_DRIVER_OPMODE_ON_AC = "active"`
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave"; # <- `CPU_DRIVER_OPMODE_ON_BAT = "active"`

          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

          CPU_MIN_PERF_ON_AC = 100;
          CPU_MIN_PERF_ON_BAT = 10;

          CPU_MAX_PERF_ON_AC = 100;
          CPU_MAX_PERF_ON_BAT = 60;

          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;

          CPU_HWP_DYN_BOOST_ON_AC = 1;
          CPU_HWP_DYN_BOOST_ON_BAT = 1;

          # PCIe Autosuspend and ASPM
          RUNTIME_PM_ON_AC = "on";
          RUNTIME_PM_ON_BAT = "auto";

          PCIE_ASPM_ON_AC = "default";
          PCIE_ASPM_ON_BAT = "powersupersave";

          # USB Autosuspend
          USB_AUTOSUSPEND_ON_AC = 0;
          USB_AUTOSUSPEND_ON_BAT = 1;
        };

        pd = {
          enable = true;
          package = pkgs.unstable.tlp-pd;
        };
      };
    };
  };
}
