{den, ...}: {
  den.aspects.apps.terminals = {
    includes = [
      den.aspects.apps.terminals.st
      den.aspects.apps.terminals.ghostty
    ];
  };
}
