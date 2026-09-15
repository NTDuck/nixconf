{den, ...}: {
  den.aspects.desktop.shells = {
    includes = [
      den.aspects.desktop.shells.prompts
      den.aspects.desktop.shells.zsh
    ];
  };
}
