{den, ...}: {
  den.aspects.rtorrent = {
    home-manager = {pkgs, ...}: {
      programs.rtorrent = {
        enable = true;
        package = pkgs.unstable.rtorrent;
      };
    };
  };
}
