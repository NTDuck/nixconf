{den, ...}: {
  den.aspects.apps.multimedia.ffmpeg = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.ffmpeg
      ];
    };
  };
}
