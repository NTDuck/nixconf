{
  flake.modules.homeManager.glab = {
    pkgs,
    config,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    home.packages = [
      pkgs.unstable.glab
    ];

    programs.git.settings = {
      credential."https://gitlab.com".helper = "!${pkgs.unstable.glab}/bin/glab auth git-credential";
    };
  };
}
