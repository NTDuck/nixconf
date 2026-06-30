{den, ...}: {
  den.aspects.dev = {
    includes = [
      den.aspects.dev.agentics
      den.aspects.dev.gits
      den.aspects.dev.toolchains
    ];
  };
}
