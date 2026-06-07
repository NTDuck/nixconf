{
  inputs,
  config,
  ...
}: let
  username = config.this.username;
  hostname = config.this.hostname;
in {
  flake.modules.homeManager.cliphist = {
    pkgs,
    config,
    lib,
    ...
  }: {
    services.cliphist = {
      enable = true;
      package = pkgs.unstable.cliphist;

      allowImages = true;
    };
  };
}
