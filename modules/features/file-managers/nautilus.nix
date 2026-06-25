{den, ...}: {
  den.aspects.file-managers.nautilus = {
    includes = [
      den.aspects.services.gvfs
      den.aspects.services.udisks2
    ];

    nixos = {
      programs.nautilus = {
        enable = true;
      };
    };
  };
}
