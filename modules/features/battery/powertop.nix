{den, ...}: {
  den.aspects.battery.powertop = {
    nixos = {pkgs, ...}: {
      powerManagement.powertop = {
        enable = true;
      };
    };
  };
}
