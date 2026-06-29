{den, ...}: {
  den.aspects.terminals.kitty = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.kitty-img
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.kitty = {
        enable = true;
        package = pkgs.unstable.kitty;

        # font.size = 16;

        # https://sw.kovidgoyal.net/kitty/conf.html
        settings = {
          cursor_shape = "block";
          cursor_shape_unfocus = "unchanged";
          cursor_blink_interval = "0";
          cursor_trail = 100;

          window_padding_width = "20 28";
        };
      };
    };
  };
}
