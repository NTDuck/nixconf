{den, ...}: {
  den.aspects.apps.glow = {
    # charmbracelet/glow (2026-11-11 user request): terminal markdown
    # renderer. Used standalone and as yazi's markdown previewer (see
    # apps.file-managers.yazi's preloader config).
    homeManager = {
      pkgs,
      ...
    }: {
      home.packages = [
        pkgs.glow
      ];

      xdg.configFile."glow/glow.yml".text = ''
        # TTY-adaptive: glow picks light/dark from the terminal palette.
        style: auto
        # Wide layout for preview panes; pager for long docs.
        pager: true
      '';
    };
  };
}
