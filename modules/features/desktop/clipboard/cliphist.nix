{den, ...}: {
  den.aspects.desktop.clipboard.cliphist = {
    homeManager = {pkgs, ...}: {
      services.cliphist = {
        enable = true;
        package = pkgs.unstable.cliphist;

        allowImages = true;
      };
    };
  };
}
