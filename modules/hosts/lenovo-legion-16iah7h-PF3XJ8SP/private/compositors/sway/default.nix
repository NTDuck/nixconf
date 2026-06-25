{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.compositors.sway = {
    homeManager = {
      wayland.windowManager.sway.config = {
        output = {
          "eDP-1" = {
            mode = "2560x1600@165.019Hz";
          };
        };
        extraConfig = ''
          output eDP-1 scale 1.5
        '';
      };
    };
  };
}
