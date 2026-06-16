{den, ...}: {
  den.aspects.system-state-version = {
    nixos = { lib, ... }: {
      system.stateVersion = lib.mkDefault "26.05";
    };
  };
}
