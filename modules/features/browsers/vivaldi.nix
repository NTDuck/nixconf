{den, ...}: {
  den.aspects.browsers.vivaldi = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.vivaldi];};
  };
}
