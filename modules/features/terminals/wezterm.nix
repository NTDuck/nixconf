{den, ...}: {
  den.aspects.wezterm = {
    homeManager = {pkgs, ...}: {
      programs.wezterm.enable = true;
      programs.wezterm.package = pkgs.unstable.wezterm;
    };
  };
}
