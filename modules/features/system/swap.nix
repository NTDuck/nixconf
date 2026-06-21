{den, ...}: {
  den.aspects.swap = {
    nixos = {
      zramSwap.enable = true;
    };
  };
}
