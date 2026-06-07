{
  flake.modules.homeManager.mpv = {
    pkgs,
    config,
    lib,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    programs.mpv = {
      enable = true;
      package = pkgs.unstable.mpv;
    };
  };
}
