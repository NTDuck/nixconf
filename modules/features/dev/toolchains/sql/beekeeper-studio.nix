{den, ...}: {
  den.aspects.dev.toolchains.sql.beekeeper-studio = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.beekeeper-studio
      ];
    };
  };
}
