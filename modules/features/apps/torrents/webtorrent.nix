{den, ...}: {
  den.aspects.apps.torrents.webtorrent = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.webtorrent_desktop
      ];
    };
  };
}
