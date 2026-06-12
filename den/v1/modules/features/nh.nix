{den, ...}: {
  den.aspects.nh = {
    nixos = {...}: {
      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 7d --keep 3";
      };
    };
  };
}
