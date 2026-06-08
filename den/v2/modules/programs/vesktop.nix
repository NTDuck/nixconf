{
  flake.modules.homeManager.vesktop = {
    pkgs,
    config,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    programs.vesktop = {
      enable = true;
      package = pkgs.unstable.vesktop;
    };
  };
}
