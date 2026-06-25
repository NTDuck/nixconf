{den, ...}: {
  den.aspects.file-managers.thunar = {
    nixos = {
      programs.thunar = {
        enable = true;
      };
    };
  };
}
