{
  flake.modules.homeManager.imv = {
    pkgs,
    config,
    ...
  }: {
    programs.imv = {
      enable = true;
      package = pkgs.unstable.imv;
    };
  };
}
