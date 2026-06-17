{den, ...}: {
  den.aspects.webtorrent = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.webtorrent_desktop];};
  };
}
