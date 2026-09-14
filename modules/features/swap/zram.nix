{den, ...}: {
  den.aspects.swap.zram = {
    nixos = {
      zramSwap = {
        enable = true;
        memoryPercent = 100;
      };
    };
  };
}
