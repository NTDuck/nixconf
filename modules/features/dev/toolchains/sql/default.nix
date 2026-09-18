{den, ...}: {
  den.aspects.dev.toolchains.sql = {
    includes = [
      den.aspects.dev.toolchains.sql.beekeeper-studio
      den.aspects.dev.toolchains.sql.mysql
      den.aspects.dev.toolchains.sql.postgresql
      den.aspects.dev.toolchains.sql.dbeaver
      den.aspects.dev.toolchains.sql.harlequin
    ];
  };
}
