{den, ...}: {
  den.aspects.desktop.settings.dconf = {
    nixos = {
      programs.dconf = {
        enable = true;
      };
    };
  };
}
