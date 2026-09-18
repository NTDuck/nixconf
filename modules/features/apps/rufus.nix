{den, ...}: {
  den.aspects.apps.rufus = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.impression
      ];
    };
  };
}
