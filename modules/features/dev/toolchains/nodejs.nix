{den, ...}: {
  den.aspects.nodejs = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.unstable.nodejs];
    };
  };
}
