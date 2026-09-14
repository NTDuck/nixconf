{den, ...}: {
  den.aspects.system.hardware.openrgb = {
    nixos = {pkgs, ...}: {
      services.hardware.openrgb = {
        enable = true;
        package = pkgs.unstable.openrgb;
      };
    };
  };
}
