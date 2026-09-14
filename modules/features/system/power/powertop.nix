{den, ...}: {
  den.aspects.system.power.powertop = {
    nixos = {
      powerManagement.powertop = {
        enable = true;
      };
    };
  };
}
