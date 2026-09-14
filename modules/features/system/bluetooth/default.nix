{den, ...}: {
  den.aspects.bluetooth = {
    includes = [
      den.aspects.bluetooth.bluetuith
    ];

    nixos = {pkgs, ...}: {
      hardware.bluetooth = {
        enable = true;
        package = pkgs.unstable.bluez;

        powerOnBoot = true;
        settings = {
          General = {
            Experimental = true;
          };
        };
      };
    };
  };
}
