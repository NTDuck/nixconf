{den, ...}: {
  den.aspects.apps.office.pandoc = {
    homeManager = {pkgs, ...}: {
      programs.pandoc = {
        enable = true;
        package = pkgs.unstable.pandoc;
      };
    };
  };
}
