{den, ...}: {
  den.aspects.cava = {
    home-manager = {pkgs, ...}: {
      programs.cava = {
        enable = true;
        package = pkgs.unstable.cava;
      };
    };
  };
}
