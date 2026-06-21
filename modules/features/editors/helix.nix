{den, ...}: {
  den.aspects.helix = {
    homeManager = {pkgs, ...}: {
      programs.helix = {
        enable = true;
        package = pkgs.unstable.helix;

        defaultEditor = true;

        settings = {
          editor = {
            line-number = "relative";
            lsp.display-messages = true;
            cursor-shape = {
              insert = "bar";
              normal = "block";
              select = "underline";
            };
          };
          keys.normal = {
            space.space = "file_picker";
            space.w = ":w";
            space.q = ":q";
            "esc" = ["collapse_selection" "keep_primary_selection"];
          };
        };

        languages = {
          language = [
            {
              name = "nix";
              auto-format = true;
              formatter = {
                command = "alejandra";
                args = ["--quiet"];
              };
            }
          ];
        };
      };

      home.sessionVariables = {
        EDITOR = "hx";
      };
    };
  };
}
