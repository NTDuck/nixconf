{den, ...}: {
  den.aspects.battery.upower = {
    nixos = {pkgs, ...}: {
      services.upower = {
        enable = true;
        package = pkgs.unstable.upower;

        usePercentageForPolicy = true;
        noPollBatteries = true;

        percentageLow = 10;
        percentageCritical = 5;
        percentageAction = 2;

        allowRiskyCriticalPowerAction = true;
        criticalPowerAction = "Hibernate";
      };
    };
  };
}
