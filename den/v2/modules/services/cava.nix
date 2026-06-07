{
  inputs,
  config,
  ...
}: let
  username = config.this.username;
  hostname = config.this.hostname;
in {
  flake.modules.homeManager.cava = {
    pkgs,
    config,
    lib,
    ...
  }: {
    home.packages = [
      pkgs.unstable.cava
    ];
  };
}
