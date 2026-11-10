{den, ...}: {
  den.aspects.apps.sql.harlequin = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.harlequin
      ];
    };
  };
}
