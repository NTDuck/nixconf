# pcmanfm — lightweight GTK file manager for the DELL X11 session,
# replacing nemo (2026-09-22). pcmanfm is the canonical LXDE/X11 file
# manager; smaller dep than nemo (no cinnamon-desktop deps).
{den, ...}: {
  den.aspects.apps.file-managers.pcmanfm = {
    includes = [
      den.aspects.desktop.fs.gvfs
      den.aspects.system.storage.udisks2
    ];

    homeManager = {pkgs, ...}: {
      # gio/xdg-mime rewrite this file in place on GUI default-app changes,
      # leaving a regular file that collides with the next activation's
      # backup under backupFileExtension (linkGeneration mv overwrites the
      # stale .backup, so force + backup self-heals every switch).
      xdg.configFile."mimeapps.list".force = true;

      # HM mirrors the same file to the deprecated data-home location
      # (xdg-mime-apps.nix copies only .source, not force); force it too
      # so a tool rewriting that copy can't brick activation either.
      xdg.dataFile."applications/mimeapps.list".force = true;

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = ["pcmanfm.desktop"];
          "application/x-gnome-saved-search" = ["pcmanfm.desktop"];
        };
      };

      home.packages = [
        pkgs.unstable.pcmanfm
      ];
    };
  };
}
