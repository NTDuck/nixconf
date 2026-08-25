{den, ...}: {
  den.aspects.utilities.screenshots.gpu-screen-recorder = {
    nixos = {pkgs, ...}: {
      programs.gpu-screen-recorder = {
        enable = true;
        package = pkgs.unstable.gpu-screen-recorder;
      };
    };
  };
}
