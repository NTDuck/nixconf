{den, ...}: {
  den.aspects.mangohud = {
    homeManager = {pkgs, ...}: {
      programs.mangohud = {
        enable = true;
        package = pkgs.unstable.mangohud;
      };
    };
  };
}
