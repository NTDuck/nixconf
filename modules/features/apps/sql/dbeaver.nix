{den, ...}: {
  den.aspects.dev.toolchains.sql.dbeaver = {
    homeManager = {pkgs, ...}: {
      programs.dbeaver = {
        enable = true;
        package = pkgs.unstable.dbeaver-bin;
      };
    };
  };
}
