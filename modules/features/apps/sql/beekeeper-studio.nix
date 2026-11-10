{den, ...}: {
  den.aspects.apps.sql.beekeeper-studio = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.beekeeper-studio
      ];
    };
  };
}
