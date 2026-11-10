{den, ...}: {
  den.aspects.apps.editors = {
    includes = [
      den.aspects.apps.editors.helix
      den.aspects.apps.editors.openidea
      den.aspects.apps.editors.emeraldian
      den.aspects.apps.editors.obsidian
      den.aspects.apps.editors.zed-editor
      # Declared but unincluded everywhere (2026-11-10 user request:
      # intellij un-included for legion); listed here only so the
      # umbrella covers every file in the dir.
      den.aspects.apps.editors.intellij
    ];
  };
}
