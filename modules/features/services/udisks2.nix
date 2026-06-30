{den, ...}: {
  den.aspects.services.udisks2 = {
    nixos = {
      services.udisks2 = {
        enable = true;
      };
    };
  };
}
