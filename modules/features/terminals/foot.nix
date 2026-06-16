{
  den,
  inputs,
  ...
}: {
  den.aspects.foot = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.foot
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.foot = {
        enable = true;
        # package = pkgs.unstable.foot;

        server.enable = true;

        settings = {
          main = {
            # font = "Maple Mono:size=11";
            # dpi-aware = "yes";
          };
          mouse = {
            hide-when-typing = "yes";
          };
        };
      };

      home.sessionVariables = {
        TERMINAL = "foot";
      };
    };
  };
}
