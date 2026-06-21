{den, ...}: {
  den.aspects.ffmpeg = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.ffmpeg
      ];
    };
  };
}
