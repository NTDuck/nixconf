{den, ...}: {
  den.aspects.pandoc = {
    homeManager = {pkgs, ...}: {
      programs.pandoc = {
        enable = true;
        package = pkgs.unstable.pandoc;
      };
    };
  };
}
