{
  inputs,
  config,
  ...
}: let
  username = config.this.username;
  hostname = config.this.hostname;
in {
  flake.modules.homeManager.glab = {
    pkgs,
    config,
    lib,
    ...
  }: {
    home.packages = [
      pkgs.unstable.glab
    ];

    programs.git.settings = {
      credential."https://gitlab.com".helper = "!${pkgs.unstable.glab}/bin/glab auth git-credential";
    };
  };
}
