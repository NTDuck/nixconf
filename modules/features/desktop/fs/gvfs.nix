{den, ...}: {
  den.aspects.desktop.fs.gvfs = {
    nixos = {
      services.gvfs = {
        enable = true;
      };
    };
  };
}
