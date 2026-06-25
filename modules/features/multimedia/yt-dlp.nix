{den, ...}: {
  den.aspects.multimedia.yt-dlp = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.yt-dlp
      ];
    };
  };
}
