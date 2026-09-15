{den, ...}: {
  den.aspects.desktop.shells.prompts = {
    includes = [
      den.aspects.desktop.shells.prompts.powerlevel10k
      den.aspects.desktop.shells.prompts.starship
    ];
  };
}
