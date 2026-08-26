{den, ...}: {
  den.aspects.dev = {
    includes = [
      den.aspects.dev.agentics
      den.aspects.dev.envs
      den.aspects.dev.gits
      den.aspects.dev.toolchains

      den.aspects.dev.google-cloud-sdk
      den.aspects.dev.postman
    ];
  };
}
