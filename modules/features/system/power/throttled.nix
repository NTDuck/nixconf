{den, ...}: {
  den.aspects.system.power.throttled = {
    nixos = {
      services.throttled = {
        enable = true;
      };
    };
  };
}
