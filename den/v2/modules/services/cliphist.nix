{
  flake.modules.homeManager.cliphist = {
    pkgs,
    config,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    services.cliphist = {
      enable = true;
      package = pkgs.unstable.cliphist;

      allowImages = true;
    };
  };
}
