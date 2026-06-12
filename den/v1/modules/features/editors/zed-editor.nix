{ den, inputs, ... }: {
  den.aspects.zedEditor = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      programs.zed-editor = {
        enable = true;

        # https://github.com/zed-industries/zed/issues/32792
        package = pkgs.symlinkJoin {
          name = "zed";
          paths = [pkgs.unstable.zed-editor];
          buildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/zeditor \
              --unset WAYLAND_DISPLAY
          '';
        };

        extensions = [
          # "catppuccin-blur"
          "catppuccin-icons"

          "nix"

          "toml"
          "rust"
          "crates"
        ]; # https://github.com/zed-industries/extensions/tree/main/extensions

        userSettings = {
          features.copilot = false;

          telemetry = {
            diagnostics = false;
            metrics = false;
          };

          languages = {
            Nix = {
              language_servers = ["nixd"];
              format_on_save = "on";
              formatter = {
                external = {
                  command = "alejandra";
                  arguments = ["--quiet"];
                };
              };
            };
          };

          session.trust_all_worktrees = true;
          base_keymap = "VSCode";
          soft_wrap = "editor_width";

          buffer_font_size = lib.mkForce 11;
          ui_font_size = lib.mkForce 11;

          # icon_theme = lib.mkForce "Catppuccin Latte";
        };
      };

      home.shellAliases = {
        zed = "zeditor";
        # zed = "${pkgs.unstable.zed}/bin/zeditor";
      };
    };
  };
}
