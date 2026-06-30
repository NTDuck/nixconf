{den, ...}: {
  den.aspects.multimedia.gallery-dl = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.gallery-dl
      ];
    };
  };
}
