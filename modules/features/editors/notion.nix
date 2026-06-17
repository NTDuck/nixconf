{den, ...}: {
  den.aspects.notion = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.notion-app-enhanced];};
  };
}
