{
  inputs,
  config,
  ...
}: let
  username = config.this.username;
  hostname = config.this.hostname;
in {
  flake.modules.homeManager.vesktop = {
    pkgs,
    config,
    lib,
    ...
  }: {
    programs.vesktop = {
      enable = true;
      package = pkgs.unstable.vesktop;
    };
  };
}
