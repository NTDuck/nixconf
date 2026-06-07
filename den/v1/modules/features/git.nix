{inputs, ...}: {
  flake.modules.homeManager.git = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
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
