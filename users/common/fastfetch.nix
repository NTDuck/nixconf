{ ... }:

{
  programs.fastfetch = {
    enable = true;
  };

  programs.zsh.shellAliases = {
    ff = "fastfetch";
  };
}
