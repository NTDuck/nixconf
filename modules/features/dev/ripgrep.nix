{den, ...}: {
  den.aspects.ripgrep = {
    homeManager = {pkgs, ...}: {
      programs.ripgrep = {
        enable = true;
        package = pkgs.unstable.ripgrep;
      };
    };
  };
}
