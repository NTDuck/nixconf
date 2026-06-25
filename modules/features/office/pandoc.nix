{den, ...}: {
  den.aspects.office.pandoc = {
    home-manager = {pkgs, ...}: {
      programs.pandoc = {
        enable = true;
        package = pkgs.unstable.pandoc;
      };
    };
  };
}
