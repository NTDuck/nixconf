{den, ...}: {
  den.aspects.nh = {
    nixos = {pkgs, ...}: {
      programs.nh = {
        enable = true;
        package = pkgs.unstable.nh;

        clean = {
          enable = true;
          dates = "daily";
          # 2026-09-14: --keep-since 4d kept every generation because heavy
          # iteration produced 27 system gens inside 4d, so the daily job
          # freed nothing from profiles. 1d + keep 5 actually reclaims; the
          # journal (daily 2-50 GiB freed) showed the timer itself was fine.
          extraArgs = "--keep-since 1d --keep 5 --optimise";
        };
      };
    };
  };
}
