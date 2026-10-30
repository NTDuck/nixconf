{den, ...}: {
  den.aspects.apps.pciutils = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.pciutils
      ];
    };
  };
}
