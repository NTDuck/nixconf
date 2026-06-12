{ den, inputs, ... }: {
  den.aspects.helix = {
    homeManager = {pkgs, ...}: {
      programs.helix = {
        enable = true;
        package = pkgs.unstable.helix;

        defaultEditor = true;

        settings = {
          editor = {
            soft-wrap.enable = true;
          };
        };

        languages = {
          language = [
            {
              name = "nix";
              auto-format = true;
              formatter = {
                command = "${pkgs.unstable.alejandra}/bin/alejandra";
                args = ["--quiet"];
              };
              language-servers = ["${pkgs.unstable.nixd}/bin/nixd"];
            }
          ];
        };
      };
    };
  };
}
