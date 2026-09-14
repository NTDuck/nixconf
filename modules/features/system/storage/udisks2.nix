{den, ...}: {
  den.aspects.system.storage.udisks2 = {
    nixos = {
      services.udisks2 = {
        enable = true;
      };
    };
  };
}
