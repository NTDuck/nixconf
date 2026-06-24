{den, ...}: {
  den.aspects.yt-dlp = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.yt-dlp
      ];
    };
  };
}
