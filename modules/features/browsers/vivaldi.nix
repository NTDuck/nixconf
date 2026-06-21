{den, ...}: {
  den.aspects.vivaldi = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.vivaldi];};
  };
}
