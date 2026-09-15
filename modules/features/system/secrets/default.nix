{den, ...}: {
  den.aspects.system.secrets = {
    includes = [
      den.aspects.system.secrets.agenix
    ];
  };
}
