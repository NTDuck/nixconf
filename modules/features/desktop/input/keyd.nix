{den, ...}: {
  den.aspects.desktop.input.keyd = {
    nixos = {pkgs, ...}: {
      services.keyd = {
        enable = true;
        package = pkgs.unstable.keyd;

        keyboards = {
          rpgm = {
            ids = ["*"];

            settings = {
              # NumLock must stay a REAL NumLock (2026-09-16): keyd's
              # toggle(nav) on it swallows the raw KEY_NUMLOCK/LED_NUML
              # events, so the laptop's NumLock indicator never lights.
              # The nav layer is held with rightalt instead — hold
              # rightalt+w/a/s/d for arrows, e/q for enter/esc.
              main = {
                rightalt = "layer(nav)";
              };

              nav = {
                w = "up";
                a = "left";
                s = "down";
                d = "right";

                e = "enter";
                q = "esc";
              };
            };
          };
        };
      };
    };
  };
}
