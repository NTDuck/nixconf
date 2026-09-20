{den, ...}: {
  den.aspects.apps.editors = {
    includes = [
      den.aspects.apps.editors.helix
      den.aspects.apps.editors.intellij
      den.aspects.apps.editors.obsidian
      den.aspects.apps.editors.zed-editor
    ];
  };
}
