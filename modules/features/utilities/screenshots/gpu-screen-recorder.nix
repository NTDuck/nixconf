{den, ...}: {
  den.aspects.utilities.screenshots.gpu-screen-recorder = {
    homeManager = {pkgs, ...}: {
      programs.gpu-screen-recorder = {
        enable = true;
        package = pkgs.unstable.gpu-screen-recorder;
      };
    };
  };
}
