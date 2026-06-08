{
  flake.modules.homeManager.git = {
    pkgs,
    config,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    programs.git = {
      enable = true;
      package = pkgs.unstable.git;

      settings = {
        alias = {
          nccommit = "commit -a --allow-empty-message -m ''"; # https://trunk.io/blog/git-commit-messages-are-useless
        };
      };
    };
  };
}
