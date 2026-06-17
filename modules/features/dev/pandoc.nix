{den, ...}: {
  den.aspects.pandoc = {
    homeManager = {pkgs, ...}: {
      programs.pandoc.enable = true;
      programs.pandoc.package = pkgs.unstable.pandoc;
    };
  };
}
