{den, ...}: {
  den.aspects.bluetooth = {
    includes = [
      den.aspects.bluetuith
    ];

    nixos = {pkgs, ...}: {
      hardware.bluetooth = {
        enable = true;
        package = pkgs.unstable.bluez;

        powerOnBoot = true;
      };
    };
  };
}
