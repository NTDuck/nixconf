{den, ...}: {
  den.aspects.multimedia.mpv = {
    homeManager = {pkgs, ...}: {
      programs.mpv = {
        enable = true;
        package = pkgs.unstable.mpv;
      };
    };
  };
}
