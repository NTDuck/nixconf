{den, ...}: {
  den.aspects.desktop = {
    includes = [
      den.aspects.desktop.audio
      den.aspects.desktop.auth
      den.aspects.desktop.clipboard
      den.aspects.desktop.compositors
      den.aspects.desktop.fs
      den.aspects.desktop.greeters
      den.aspects.desktop.input
      den.aspects.desktop.launchers
      den.aspects.desktop.notifications
      den.aspects.desktop.panels
      den.aspects.desktop.portals
      den.aspects.desktop.screenshots
      den.aspects.desktop.settings
      den.aspects.desktop.shells
      den.aspects.desktop.theming
      den.aspects.desktop.wayland
    ];
  };
}
