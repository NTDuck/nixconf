{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.compositors.sway = {
    homeManager = {
      lib,
      config,
      ...
    }:
      lib.mkIf (config.networking.hostName == "lenovo-legion-16iah7h-
      PF3XJ8SP") {
        wayland.windowManager.sway.config = {
          output = {
            "eDP-1" = {
              scale = "1.5";
              mode = "2560x1600@165.019Hz";
            };
          };
        };
      };
  };
}
