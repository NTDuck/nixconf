{den, ...}: {
  den.aspects.swap.zram = {
    nixos = {
      zramSwap = {
        enable = true;
      };
    };
  };
}
