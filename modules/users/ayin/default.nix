{den, ...}: {
  den.aspects.ayin = {
    includes = [
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")
      den.aspects.ayin.dev.gits.git
    ];
  };
}
