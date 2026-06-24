{den, ...}: {
  den.aspects.terminals.wezterm = {
    home-manager = {pkgs, ...}: {
      programs.wezterm = {
        enable = true;
        package = pkgs.unstable.wezterm;
      };
    };
  };
}
