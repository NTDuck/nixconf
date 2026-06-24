{den, ...}: {
  den.aspects.music.youtube-music = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.pear-desktop

        (pkgs.makeDesktopItem {
          name = "youtube-music";
          exec = "pear-desktop";
          icon = "pear-desktop";
          desktopName = "YouTube Music";
          comment = "YouTube Music Desktop Client";
          categories = ["AudioVideo" "Player" "Audio"];
        })
      ];
    };
  };
}
