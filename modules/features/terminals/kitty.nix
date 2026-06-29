{den, ...}: {
  den.aspects.terminals.kitty = {
    homeManager = {pkgs, ...}: {
      programs.kitty = {
        enable = true;
        package = pkgs.unstable.kitty;

        font.size = 16;

        # settings = {
        #   font_size = 16;

        #   window_padding = {
        #     left = 28;
        #     right = 28;
        #     top = 20;
        #     bottom = 20;
        #   };
        # };
      };
    };
  };
}
