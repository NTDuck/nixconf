{den, ...}: {
  den.aspects.desktop.audio.visualization.cava = {
    homeManager = {pkgs, ...}: {
      programs.cava = {
        enable = true;
        package = pkgs.unstable.cava;
      };
    };
  };
}
