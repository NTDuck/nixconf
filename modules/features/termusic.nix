{
  flake.modules.homeManager.termusic = {
    pkgs,
    config,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    home.packages = [
      pkgs.unstable.termusic
    ];
  };
}
