{den, ...}: {
  den.aspects.terminals.foot = {
    home-manager = {pkgs, ...}: {
      programs.foot = {
        enable = true;
        package = pkgs.unstable.foot;

        server.enable = true;

        settings = {
          main = {
            pad = "14x10";
            gamma-correct-blending = "no";
            term = "xterm-256color";
          };

          mouse = {
            hide-when-typing = "yes";
            alternate-scroll-mode = "yes";
          };
        };
      };

      home.sessionVariables = {
        # TERMINAL = "foot";
        TERMINAL = "${pkgs.unstable.foot}/bin/footclient";
      };
    };
  };
}
