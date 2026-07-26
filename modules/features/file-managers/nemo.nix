{den, ...}: {
  den.aspects.file-managers.nemo = {
    includes = [
      den.aspects.services.dconf
      den.aspects.services.gvfs
      den.aspects.services.udisks2
    ];

    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.file-roller
        pkgs.unstable.nemo-preview
        pkgs.unstable.nemo-with-extensions
      ];
    };

    homeManager = {
      lib,
      pkgs,
      ...
    }: {
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = ["nemo.desktop"];
          "application/x-gnome-saved-search" = ["nemo.desktop"];
        };
      };

      dconf.settings = {
        "org/nemo/preferences" = {
          always-use-browser = true;
          click-policy = "double";
          confirm-trash = true;
          date-format = "iso";
          default-folder-viewer = "list-view";
          default-sort-order = "name";
          executable-text-activation = "ask";
          show-advanced-permissions = true;
          show-compact-view-icon-toolbar = true;
          show-full-path-titles = true;
          show-hidden-files = false;
          show-image-thumbnails = "local-only";
          show-list-view-icon-toolbar = true;
          show-open-in-terminal-toolbar = true;
          show-toggle-extra-pane-toolbar = true;
          sort-directories-first = true;
          start-with-dual-pane = false;
        };

        "org/nemo/list-view" = {
          default-column-order = [
            "name"
            "size"
            "type"
            "date_modified"
          ];
          default-visible-columns = [
            "name"
            "size"
            "type"
            "date_modified"
          ];
          default-zoom-level = "small";
          enable-folder-expansion = true;
        };

        "org/nemo/sidebar-panels/tree" = {
          show-only-directories = true;
        };

        "org/nemo/window-state" = {
          maximized = false;
          sidebar-width = 240;
          start-with-location-bar = true;
          start-with-menu-bar = true;
          start-with-sidebar = true;
          start-with-status-bar = true;
          start-with-toolbar = true;
        };

        "org/nemo/desktop" = {
          show-desktop-icons = false;
        };
      };

      # TODO Decouple kitty
      home.file.".local/share/nemo/actions/open-kitty-here.nemo_action".text = ''
        [Nemo Action]
        Name=Open in Kitty
        Comment=Open a terminal in this folder
        Exec=${lib.getExe pkgs.unstable.kitty} --directory %F
        Icon-Name=utilities-terminal
        Selection=none
        Extensions=dir;
      '';
    };
  };
}
