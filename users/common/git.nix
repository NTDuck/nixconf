{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      alias = {
        nccommit = "commit -a --allow-empty-message -m ''";  # https://trunk.io/blog/git-commit-messages-are-useless
      };
    };
  };
}
