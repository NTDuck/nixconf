{ pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;
    package = pkgs.unstable.fastfetch;
  };

  programs.zsh.shellAliases = {
    ff = "fastfetch";
  };
}
