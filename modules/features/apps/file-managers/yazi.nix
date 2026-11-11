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
      home.packages = [
        pkgs.yazi
        pkgs.yaziPlugins.piper
      ];

      xdg.configFile."yazi/yazi.toml".text = ''
        [manager]
        ratio = [1, 3, 4]
        sort_by = "natural"
        sort_sensitive = false
        sort_reverse = false
        sort_dir_first = true
        linemode = "size"
        show_symlink = true

        [preview]
        max_width = 1920
        max_height = 1080
        tab_size = 2

        # Markdown via glow, the official piper.yazi example (yazi-rs/
        # plugins/piper README): CLICOLOR_FORCE for color in the preview
        # pane, width from $w. glow arrives from apps.glow.
        [[plugin.prepend_previewers]]
        url = "*.md"
        run = 'piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'
        [[plugin.prepend_previewers]]
        url = "*.markdown"
        run = 'piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'
      '';
    };
  };
}
