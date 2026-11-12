{den, ...}: {
  den.aspects.apps.file-managers.yazi = {
    # glow is the markdown previewer (piper pipes it); the apps.glow
    # aspect supplies the binary, so include it wherever yazi lands.
    includes = [
      den.aspects.apps.glow
    ];

    homeManager = {
      pkgs,
      ...
    }: {
      # programs.yazi (NOT home.packages + hand-rolled yazi.toml):
      # the HM module wires YAZI_PLUGIN_DIRS to the plugin packages, which
      # a bare pkgs.yaziPlugins.piper in home.packages never does - yazi
      # then fails md preview with "failed to load plugin piper" because
      # yazi.toml references a plugin it cannot find on disk.
      # `y` alias (2026-11-12 user request) since programs.yazi.package
      # does not create one.
      programs.yazi = {
        enable = true;
        plugins.piper = pkgs.yaziPlugins.piper;
        settings = {
          manager = {
            ratio = [1 3 4];
            sort_by = "natural";
            sort_sensitive = false;
            sort_reverse = false;
            sort_dir_first = true;
            linemode = "size";
            show_symlink = true;
          };

          preview = {
            max_width = 1920;
            max_height = 1080;
            tab_size = 2;
          };

          # Markdown via glow, the official piper.yazi example (yazi-rs/
          # plugins/piper README): CLICOLOR_FORCE for color in the preview
          # pane, width from $w. glow arrives from apps.glow.
          plugin = {
            prepend_previewers = [
              {
                url = "*.md";
                run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
              }
              {
                url = "*.markdown";
                run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
              }
            ];
          };
        };
      };

      home.shellAliases.y = "yazi";
    };
  };
}
