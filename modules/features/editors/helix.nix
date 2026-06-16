{
  den,
  inputs,
  ...
}: {
  den.aspects.helix = {
    # nixos = {pkgs, ...}: {
    #   environment.systemPackages = [
    #     pkgs.unstable.helix
    #   ];
    # };

    homeManager = {pkgs, ...}: {
      programs.helix = {
        enable = true;
        package = pkgs.unstable.helix;

        defaultEditor = true;

        settings = {
          # theme = "catppuccin_mocha";
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
