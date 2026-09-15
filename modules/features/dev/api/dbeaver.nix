{den, ...}: {
  den.aspects.dev.api.dbeaver = {
    homeManager = {pkgs, ...}: {
      programs.dbeaver = {
        enable = true;
        package = pkgs.unstable.dbeaver-bin;
      };
    };
  };
}
