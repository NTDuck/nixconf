{den, ...}: {
  den.aspects.dev.envs = {
    includes = [
      den.aspects.dev.envs.direnv
      den.aspects.dev.envs.mise
    ];
  };
}
