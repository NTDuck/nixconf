{den, ...}: {
  den.aspects.apps.disk.rufus = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.impression
      ];
    };
  };
}
