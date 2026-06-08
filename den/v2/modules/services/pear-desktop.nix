{
  flake.modules.homeManager.pear-desktop = {
    pkgs,
    config,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    home.packages = [
      pkgs.unstable.pear-desktop
    ];
  };
}
