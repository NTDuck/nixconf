{den, ...}: {
  den.aspects.utilities.ripgrep = {
    home-manager = {pkgs, ...}: {
      programs.ripgrep = {
        enable = true;
        package = pkgs.unstable.ripgrep;
      };
    };
  };
}
