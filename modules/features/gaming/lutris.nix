{den, ...}: {
  den.aspects.gaming.lutris = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.lutris
      ];
    };
  };
}
