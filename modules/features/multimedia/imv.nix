{den, ...}: {
  den.aspects.multimedia.imv = {
    home-manager = {pkgs, ...}: {
      programs.imv = {
        enable = true;
        package = pkgs.unstable.imv;
      };
    };
  };
}
