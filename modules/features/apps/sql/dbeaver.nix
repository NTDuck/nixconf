{den, ...}: {
  den.aspects.apps.sql.dbeaver = {
    homeManager = {pkgs, ...}: {
      programs.dbeaver = {
        enable = true;
        package = pkgs.unstable.dbeaver-bin;
      };
    };
  };
}
