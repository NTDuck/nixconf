{den, ...}: {
  den.aspects.utilities.quickshell = {
    homeManager = {pkgs, ...}: {
      programs.quickshell = {
        enable = true;
        package = pkgs.unstable.quickshell;
      };
    };
  };
}
