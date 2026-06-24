{den, ...}: {
  den.aspects.services.cliphist = {
    home-manager = {pkgs, ...}: {
      services.cliphist = {
        enable = true;
        package = pkgs.unstable.cliphist;

        allowImages = true;
      };
    };
  };
}
