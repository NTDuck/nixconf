{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.compositors.sway = {
    homeManager = {lib, ...}: {
      wayland.windowManager.sway.config = {
        output = {
          "eDP-1" = {
            scale = lib.mkForce "1.5";
            mode = lib.mkForce "2560x1600@165.019Hz";
          };
        };
      };
    };
  };
}
