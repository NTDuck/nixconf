{den, ...}: {
  den.aspects.system.storage.fstrim = {
    nixos = {
      services.fstrim = {
        enable = true;
        interval = "daily";
      };
    };
  };
}
