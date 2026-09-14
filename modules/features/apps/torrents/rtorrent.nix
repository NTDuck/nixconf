{den, ...}: {
  den.aspects.apps.torrents.rtorrent = {
    homeManager = {pkgs, ...}: {
      programs.rtorrent = {
        enable = true;
        package = pkgs.unstable.rtorrent;
      };
    };
  };
}
