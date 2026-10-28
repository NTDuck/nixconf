{den, ...}: {
  den.aspects.apps.multimedia.vlc = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.vlc
      ];
    };
  };
}
