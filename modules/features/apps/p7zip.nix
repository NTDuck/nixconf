{den, ...}: {
  den.aspects.apps.p7zip = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.p7zip
      ];
    };
  };
}
