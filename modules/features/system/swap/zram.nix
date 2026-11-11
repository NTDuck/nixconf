{den, ...}: {
  den.aspects.system.swap.zram = {
    nixos = {lib, ...}: {
      zramSwap = {
        enable = true;
        # 50% (2026-11-11 user request, was 100%): 15G RAM -> 7.5G zram,
        # leaving more uncontended RAM for resident engines (the 3090
        # stack's 12G host walls assume RAM is available). mkDefault
        # allows host-level overrides without module-system
        # duplicate-definition collisions.
        memoryPercent = lib.mkDefault 50;
      };

      # Userspace OOM killer: zram has no disk swap to fall back on, so
      # memory pressure ends in a hard freeze rather than reclaim. oomd
      # kills the offending cgroup on sustained pressure instead.
      systemd.oomd = {
        enable = true;
        enableRootSlice = true;
        enableSystemSlice = true;
        enableUserSlices = true;
      };
    };
  };
}
