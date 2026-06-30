{den, ...}: {
  den.aspects.services.cliphist = {
    homeManager = {pkgs, ...}: {
      services.cliphist = {
        enable = true;
        package = pkgs.unstable.cliphist;

        allowImages = true;
      };
    };
  };
}
