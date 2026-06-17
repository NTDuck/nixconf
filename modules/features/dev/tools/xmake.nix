{den, ...}: {
  den.aspects.xmake = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.xmake];};
  };
}
