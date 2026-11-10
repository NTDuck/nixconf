{den, ...}: {
  den.aspects.apps.tomato = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.tomato-c
      ];
    };
  };
}
