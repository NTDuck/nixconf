{
  den.aspects.\"git\" = {
    homeManager = {pkgs, ...}: {
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
  };
}
