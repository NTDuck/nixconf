{den, ...}: {
  den.aspects.apps.cli = {
    includes = [
      den.aspects.apps.cli.p7zip
      den.aspects.apps.cli.ripgrep
      den.aspects.apps.cli.zoxide
    ];
  };
}
