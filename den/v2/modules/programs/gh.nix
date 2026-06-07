{
  inputs,
  config,
  ...
}: let
  username = config.this.username;
  hostname = config.this.hostname;
in {
  flake.modules.homeManager.gh = {
    pkgs,
    config,
    lib,
    ...
  }: {
    programs.gh = {
      enable = true;
      package = pkgs.unstable.gh;

      gitCredentialHelper.enable = true;
    };
  };
}
