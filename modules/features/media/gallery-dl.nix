{den, ...}: {
  den.aspects.gallery-dl = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.gallery-dl];};
  };
}
