{den, ...}: {
  den.aspects.utilities.webtorrent = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.webtorrent_desktop
      ];
    };
  };
}
