{den, ...}: {
  den.aspects.multimedia.obs-studio = {
    home-manager = {pkgs, ...}: {
      programs.obs-studio = {
        enable = true;
        package = pkgs.unstable.obs-studio;
      };
    };
  };
}
