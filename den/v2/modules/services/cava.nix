{
  flake.modules.homeManager.cava = {
    pkgs,
    config,
    lib,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    home.packages = [
      pkgs.unstable.cava
    ];
  };
}
