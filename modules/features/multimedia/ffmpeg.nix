{den, ...}: {
  den.aspects.multimedia.ffmpeg = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.ffmpeg
      ];
    };
  };
}
