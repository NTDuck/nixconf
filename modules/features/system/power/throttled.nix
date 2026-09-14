{den, ...}: {
  den.aspects.battery.throttled = {
    nixos = {
      services.throttled = {
        enable = true;
      };
    };
  };
}
