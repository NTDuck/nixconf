{den, ...}: {
  den.aspects.gaming.mangohud = {
    homeManager = {pkgs, ...}: {
      programs.mangohud = {
        enable = true;
        package = pkgs.unstable.mangohud;
      };
    };
  };
}
