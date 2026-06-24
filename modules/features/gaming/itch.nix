{den, ...}: {
  den.aspects.gaming.itch = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.itch
      ];
    };
  };
}
