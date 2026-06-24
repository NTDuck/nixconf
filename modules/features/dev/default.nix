{den, ...}: {
  den.aspects.dev = {
    includes = [
      den.aspects.agentics
      den.aspects.gits
      den.aspects.toolchains
    ];
  };
}
