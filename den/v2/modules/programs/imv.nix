{
  flake.modules.homeManager.imv = {
    pkgs,
    config,
    lib,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    programs.imv = {
      enable = true;
      package = pkgs.unstable.imv;
    };
  };
}
