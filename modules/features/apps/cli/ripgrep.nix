{den, ...}: {
  den.aspects.apps.cli.ripgrep = {
    homeManager = {pkgs, ...}: {
      programs.ripgrep = {
        enable = true;
        package = pkgs.unstable.ripgrep;
      };
    };
  };
}
