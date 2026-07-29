{den, ...}: {
  den.aspects.utilities.torrents.rtorrent = {
    homeManager = {pkgs, ...}: {
      programs.rtorrent = {
        enable = true;
        package = pkgs.unstable.rtorrent;
      };
    };
  };
}
