{den, ...}: {
  den.aspects.obs-studio = {
    homeManager = {pkgs, ...}: {
      programs.obs-studio.enable = true;
      programs.obs-studio.package = pkgs.unstable.obs-studio;
    };
  };
}
