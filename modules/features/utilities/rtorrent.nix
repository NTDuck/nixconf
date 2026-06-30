{den, ...}: {
  den.aspects.utilities.rtorrent = {
    homeManager = {pkgs, ...}: {
      programs.rtorrent = {
        enable = true;
        package = pkgs.unstable.rtorrent;
      };
    };
  };
}
