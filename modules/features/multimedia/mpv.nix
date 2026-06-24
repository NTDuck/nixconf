{den, ...}: {
  den.aspects.multimedia.mpv = {
    home-manager = {pkgs, ...}: {
      programs.mpv = {
        enable = true;
        package = pkgs.unstable.mpv;
      };
    };
  };
}
