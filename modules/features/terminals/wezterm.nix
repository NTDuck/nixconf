{den, ...}: {
  den.aspects.terminals.wezterm = {
    homeManager = {pkgs, ...}: {
      programs.wezterm = {
        enable = true;
        package = pkgs.unstable.wezterm;
      };
    };
  };
}
