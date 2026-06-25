{den, ...}: {
  den.aspects.utilities.cava = {
    home-manager = {pkgs, ...}: {
      programs.cava = {
        enable = true;
        package = pkgs.unstable.cava;
      };
    };
  };
}
