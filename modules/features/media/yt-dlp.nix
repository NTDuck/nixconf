{den, ...}: {
  den.aspects.yt-dlp = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.yt-dlp];};
  };
}
