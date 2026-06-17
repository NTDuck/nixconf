{den, ...}: {
  den.aspects.ffmpeg = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.ffmpeg];};
  };
}
