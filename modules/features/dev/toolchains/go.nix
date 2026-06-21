{den, ...}: {
  den.aspects.go = {
    homeManager = {pkgs, ...}: {
      programs.go = {
        enable = true;
        package = pkgs.unstable.go;
      };
    };
  };
}
