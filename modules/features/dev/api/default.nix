{den, ...}: {
  den.aspects.dev.api = {
    includes = [
      den.aspects.dev.api.dbeaver
      den.aspects.dev.api.harlequin
      den.aspects.dev.api.postman
    ];
  };
}
