{den, ...}: {
  den.aspects.browsers.vivaldi = {
    home-manager = {pkgs, ...}: {home.packages = [pkgs.unstable.vivaldi];};
  };
}
