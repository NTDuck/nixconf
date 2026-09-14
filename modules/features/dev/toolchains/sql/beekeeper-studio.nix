{den, ...}: {
  den.aspects.dev.toolchains.sql.dbeaver = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.beekeeper-studio
      ];
    };
  };
}
