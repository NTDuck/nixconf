{den, ...}: {
  den.aspects.apps.gaming.lutris = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.lutris
      ];
    };
  };
}
