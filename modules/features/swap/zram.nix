{den, ...}: {
  den.aspects.swap.zram = {
    nixos = {
      zramSwap = {
        enable = true;
        memoryPercent = 100;
      };

      # Userspace OOM killer: zram has no disk swap to fall back on, so
      # memory pressure ends in a hard freeze rather than reclaim. oomd
      # kills the offending cgroup on sustained pressure instead.
      services.oomd = {
        enable = true;
        killUserSessions = false;
      };
    };
  };
}
