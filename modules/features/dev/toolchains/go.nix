{den, ...}: {
  den.aspects.dev.toolchains.go = {
    home-manager = {pkgs, ...}: {
      programs.go = {
        enable = true;
        package = pkgs.unstable.go;
      };
    };
  };
}
