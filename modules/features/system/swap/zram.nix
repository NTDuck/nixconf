{den, ...}: {
  den.aspects.system.swap.zram = {
    nixos = {lib, ...}: {
      zramSwap = {
        enable = true;
        # mkDefault allows host-level overrides (e.g. Dell caps at 50%) without
        # module-system duplicate-definition collisions.
        memoryPercent = lib.mkDefault 100;
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
