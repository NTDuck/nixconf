{den, ...}: {
  den.aspects.battery.powertop = {
    nixos = {
      powerManagement.powertop = {
        enable = true;
      };
    };
  };
}
