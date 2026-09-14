{den, ...}: {
  den.aspects.apps.multimedia.yt-dlp = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.yt-dlp
      ];
    };
  };
}
