{den, ...}: {
  den.aspects.services.dconf = {
    nixos = {
      programs.dconf = {
        enable = true;
      };
    };
  };
}
