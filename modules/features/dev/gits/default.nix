{den, ...}: {
  den.aspects.dev.gits = {
    includes = [
      den.aspects.dev.gits.gh
      den.aspects.dev.gits.git
      den.aspects.dev.gits.git-xet
      den.aspects.dev.gits.glab
    ];
  };
}
