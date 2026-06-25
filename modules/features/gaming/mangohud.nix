{den, ...}: {
  den.aspects.gaming.mangohud = {
    home-manager = {pkgs, ...}: {
      programs.mangohud = {
        enable = true;
        package = pkgs.unstable.mangohud;
      };
    };
  };
}
