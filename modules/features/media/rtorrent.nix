{den, ...}: {
  den.aspects.rtorrent = {
    homeManager = {pkgs, ...}: {
      programs.rtorrent = {
        enable = true;
        package = pkgs.unstable.rtorrent;
      };
    };
  };
}
