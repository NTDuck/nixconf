{ den, inputs, ... }: {
  den.aspects.imv = {
    homeManager = {
      pkgs,
      config,
      ...
    }: {
      programs.imv = {
        enable = true;
        package = pkgs.unstable.imv;
      };
    };
  };
}
