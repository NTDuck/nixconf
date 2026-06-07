{
  inputs,
  config,
  ...
}: let
  username = config.this.username;
  hostname = config.this.hostname;
in {
  flake.modules.homeManager.imv = {
    pkgs,
    config,
    lib,
    ...
  }: {
    programs.imv = {
      enable = true;
      package = pkgs.unstable.imv;
    };
  };
}
