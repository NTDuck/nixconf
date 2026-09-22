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
