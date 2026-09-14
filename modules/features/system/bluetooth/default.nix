{den, ...}: {
  den.aspects.system.bluetooth = {
    includes = [
      den.aspects.system.bluetooth.bluetuith
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
