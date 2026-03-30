{ ... }:

{
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      RUNTIME_PM_ON_BAT = "auto";
    };
  };

  services.fstrim.enable = true;

  services.thermald.enable = true;
  powerManagement.powertop.enable = true;

  services.power-profiles-daemon.enable = false;
}
