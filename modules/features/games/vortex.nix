{den, ...}: {
  den.aspects.vortex = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.bottles];};
  };
}
