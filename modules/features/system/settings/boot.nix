{den, ...}: {
  den.aspects.system-boot = {
    nixos = {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      zramSwap.enable = true;
    };
  };
}
