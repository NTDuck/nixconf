{den, ...}: {
  den.aspects.gradle = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.gradle];};
  };
}
