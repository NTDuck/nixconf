{den, ...}: {
  den.aspects.itch = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.itch
      ];
    };
  };
}
