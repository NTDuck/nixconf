{den, ...}: {
  den.aspects.dev.toolchains.go = {
    homeManager = {pkgs, ...}: {
      programs.go = {
        enable = true;
        package = pkgs.unstable.go;
      };
    };
  };
}
