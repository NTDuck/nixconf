{den, ...}: {
  den.aspects.system.boot.systemd = {
    nixos = {
      boot.loader = {
        timeout = 4;

        efi.canTouchEfiVariables = true;

        systemd-boot = {
          enable = true;
          consoleMode = "auto";
        };
      };
    };
  };
}
