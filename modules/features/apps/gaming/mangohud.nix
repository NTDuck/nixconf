{den, ...}: {
  den.aspects.apps.gaming.mangohud = {
    homeManager = {pkgs, ...}: {
      programs.mangohud = {
        enable = true;
        package = pkgs.unstable.mangohud;

        # enableSessionWide = true;
      };
    };
  };
}
