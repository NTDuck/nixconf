{ ... }:

{
  programs.git.enable = true;
  programs.git.settings.aliases.nccommit = "commit -a --allow-empty-message -m ''";  # https://trunk.io/blog/git-commit-messages-are-useless

  programs.gh.enable = true;
  programs.gh.gitCredentialHelper.enable = true;
}
