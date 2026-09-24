{den, ...}: {
  den.aspects.apps.terminals = {
    includes = [
      den.aspects.apps.terminals.urxvt
      den.aspects.apps.terminals.foot
      den.aspects.apps.terminals.ghostty
    ];
  };
}
