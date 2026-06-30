{den, ...}: {
  den.aspects.utilities.ripgrep = {
    homeManager = {pkgs, ...}: {
      programs.ripgrep = {
        enable = true;
        package = pkgs.unstable.ripgrep;
      };
    };
  };
}
