{den, ...}: {
  den.aspects.gradle = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.gradle];};
  };
}
