{den, ...}: {
  den.aspects.apps.torrents = {
    includes = [
      den.aspects.apps.torrents.rtorrent
      den.aspects.apps.torrents.torrent-tui
      den.aspects.apps.torrents.webtorrent
    ];
  };
}
