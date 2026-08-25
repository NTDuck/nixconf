{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {lib, ...}: {
      # TODO Set this somehow
      # boot.loader.systemd-boot.consoleMode = lib.mkForce "10";
    };
  };
}
