{
  inputs,
  config,
  ...
}: let
  username = config.this.username;
  hostname = config.this.hostname;
in {
  flake.modules.homeManager.mpv = {
    pkgs,
    config,
    lib,
    ...
  }: {
    programs.mpv = {
      enable = true;
      package = pkgs.unstable.mpv;
    };
  };
}
