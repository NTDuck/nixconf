{den, ...}: {
  den.aspects.p7zip = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.unstable.p7zip];
    };
  };
}
