{
  flake.modules.homeManager.gh = {
    pkgs,
    config,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    programs.gh = {
      enable = true;
      package = pkgs.unstable.gh;

      gitCredentialHelper.enable = true;
    };
  };
}
