{den, ...}: {
  den.aspects.nh = {
    nixos = {pkgs, ...}: {
      programs.nh = {
        enable = true;
        package = pkgs.unstable.nh;

        clean = {
          enable = true;
          dates = "daily";
          extraArgs = "--keep-since 4d --keep 4";
        };
      };
    };
  };
}
