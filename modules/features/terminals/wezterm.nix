{den, ...}: {
  den.aspects.terminals.wezterm = {
    homeManager = {pkgs, ...}: {
      programs.wezterm = {
        enable = true;
        package = pkgs.unstable.wezterm;

        settings = {
          font_size = 16;

          window_padding = {
            left = 28;
            right = 28;
            top = 20;
            bottom = 20;
          };
        };
      };
    };
  };
}
