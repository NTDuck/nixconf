{den, ...}: {
  den.aspects.desktop.panels.quickshell = {
    homeManager = {pkgs, ...}: {
      programs.quickshell = {
        enable = true;
        package = pkgs.unstable.quickshell;
      };
    };
  };
}
