{den, ...}: {
  den.aspects.pandoc = {
    home-manager = {pkgs, ...}: {
      programs.pandoc = {
        enable = true;
        package = pkgs.unstable.pandoc;
      };
    };
  };
}
