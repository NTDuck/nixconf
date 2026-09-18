{den, ...}: {
  den.aspects.dev.toolchains.sql.harlequin = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.harlequin
      ];
    };
  };
}
