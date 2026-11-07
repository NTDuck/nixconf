{den, ...}: {
  den.aspects.apps.office = {
    includes = [
      den.aspects.apps.office.libreoffice
      den.aspects.apps.office.pandoc
      den.aspects.apps.office.texlive
      den.aspects.apps.office.zathura
      den.aspects.apps.office.wordcraft
      den.aspects.apps.office.gridcraft
      den.aspects.apps.office.deckcraft
    ];
  };
}
