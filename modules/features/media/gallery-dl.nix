{den, ...}: {
  den.aspects.gallery-dl = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.gallery-dl
      ];
    };
  };
}
