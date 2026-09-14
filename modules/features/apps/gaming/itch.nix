{den, ...}: {
  den.aspects.apps.gaming.itch = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.itch
      ];
    };
  };
}
