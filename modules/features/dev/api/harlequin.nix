{den, ...}: {
  den.aspects.dev.api.harlequin = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.harlequin
      ];
    };
  };
}
