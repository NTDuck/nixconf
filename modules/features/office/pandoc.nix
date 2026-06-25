{den, ...}: {
  den.aspects.office.pandoc = {
    homeManager = {pkgs, ...}: {
      programs.pandoc = {
        enable = true;
        package = pkgs.unstable.pandoc;
      };
    };
  };
}
