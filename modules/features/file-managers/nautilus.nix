{den, ...}: {
  den.aspects.file-managers.nautilus = {
    includes = [
      den.aspects.services.gvfs
      den.aspects.services.udisks2
    ];

    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.nautilus
      ];
    };
  };
}
