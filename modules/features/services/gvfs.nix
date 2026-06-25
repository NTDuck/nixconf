{den, ...}: {
  den.aspects.services.gvfs = {
    nixos = {
      services.gvfs = {
        enable = true;
      };
    };
  };
}
