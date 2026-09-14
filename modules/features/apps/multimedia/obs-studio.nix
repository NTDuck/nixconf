{den, ...}: {
  den.aspects.apps.multimedia.obs-studio = {
    homeManager = {pkgs, ...}: {
      programs.obs-studio = {
        enable = true;
        package = pkgs.unstable.obs-studio;
      };
    };
  };
}
