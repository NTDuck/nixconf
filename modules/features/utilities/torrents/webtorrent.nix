{den, ...}: {
  den.aspects.utilities.torrents.webtorrent = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.webtorrent_desktop
      ];
    };
  };
}
