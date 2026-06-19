{den, ...}: {
  den.aspects.go = {
    homeManager = {pkgs, ...}: {
      programs.go.enable = true;
      programs.go.package = pkgs.unstable.go;
    };
  };
}
