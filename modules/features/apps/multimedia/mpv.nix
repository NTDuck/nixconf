{den, ...}: {
  den.aspects.apps.multimedia.mpv = {
    homeManager = {pkgs, ...}: {
      programs.mpv = {
        enable = true;
        package = pkgs.unstable.mpv;
      };
    };
  };
}
