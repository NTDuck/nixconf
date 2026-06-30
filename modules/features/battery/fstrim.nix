{den, ...}: {
  den.aspects.battery.fstrim = {
    nixos = {
      services.fstrim = {
        enable = true;
      };
    };
  };
}
