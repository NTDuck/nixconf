{den, ...}: {
  den.aspects.utilities.cava = {
    homeManager = {pkgs, ...}: {
      programs.cava = {
        enable = true;
        package = pkgs.unstable.cava;
      };
    };
  };
}
