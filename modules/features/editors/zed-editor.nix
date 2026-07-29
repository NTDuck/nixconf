{den, ...}: {
  den.aspects.editors.zed-editor = {
    homeManager = {
      config,
      pkgs,
      ...
    }: {
      programs.zed-editor = {
        enable = true;
        package = pkgs.unstable.zed-editor;

        # https://github.com/zed-industries/extensions/tree/main/extensions
        extensions = [
          # "catppuccin-blur"
          "catppuccin-icons"

          "nix"

          "toml"
          "rust"
          "crates"
        ];

        userSettings = {
          cursor_blink = false;
          cursor_shape = "block";
          cli_default_open_behavior = "existing_window";
          format_on_save = "on";

          project_panel = {
            default_width = 240.0;
            entry_spacing = "standard";
            dock = "left";
          };

          outline_panel.dock = "left";
          collaboration_panel.dock = "left";
          git_panel.dock = "left";

          agent = {
            dock = "right";
            favourite_models = [];
            model_parameters = [];
          };

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

          # icon_theme = lib.mkForce "Catppuccin Latte";
        };
      };

      home.shellAliases = {
        zed = "${config.programs.zed-editor.package}/bin/zeditor";
      };
    };
  };
}
