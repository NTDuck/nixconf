{den, ...}: {
  den.aspects.itch = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.itch];};
  };
}
