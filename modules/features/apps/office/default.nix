{den, ...}: {
  den.aspects.apps.office = {
    includes = [
      den.aspects.apps.office.libreoffice
      den.aspects.apps.office.pandoc
      den.aspects.apps.office.texlive
      den.aspects.apps.office.zathura
    ];
  };
}
