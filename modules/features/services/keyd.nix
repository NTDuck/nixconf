{den, ...}: {
  den.aspects.services.keyd = {
    nixos = {pkgs, ...}: {
      services.keyd = {
        enable = true;
        package = pkgs.unstable.keyd;

        keyboards = {
          rpgm = {
            ids = ["*"];

            settings = {
              main = {
                numlock = "toggle(nav)";
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
