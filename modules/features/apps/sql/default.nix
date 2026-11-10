{den, ...}: {
  den.aspects.apps.sql = {
    includes = [
      den.aspects.apps.sql.beekeeper-studio
      den.aspects.apps.sql.dbeaver
      den.aspects.apps.sql.harlequin
      den.aspects.apps.sql.tabularis
    ];
  };
}
