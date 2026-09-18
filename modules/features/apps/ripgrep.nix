{den, ...}: {
  den.aspects.apps.ripgrep = {
    homeManager = {pkgs, ...}: {
      programs.ripgrep = {
        enable = true;
        package = pkgs.unstable.ripgrep;
      };
    };
  };
}
