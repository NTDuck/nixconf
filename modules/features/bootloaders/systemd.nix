{den, ...}: {
  den.aspects.bootloaders.systemd = {
    nixos = {
      boot.loader = {
        timeout = 4;

        efi.canTouchEfiVariables = true;

        systemd-boot = {
          enable = true;
          consoleMode = "max";
        };
      };
    };
  };
}
