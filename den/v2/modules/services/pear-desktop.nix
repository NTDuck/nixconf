{
  inputs,
  config,
  ...
}: let
  username = config.this.username;
  hostname = config.this.hostname;
in {
  flake.modules.homeManager.pear-desktop = {
    pkgs,
    config,
    lib,
    ...
  }: {
    home.packages = [
      pkgs.unstable.pear-desktop
    ];
  };
}
