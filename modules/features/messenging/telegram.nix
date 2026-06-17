{den, ...}: {
  den.aspects.telegram = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.telegram-desktop];};
  };
}
