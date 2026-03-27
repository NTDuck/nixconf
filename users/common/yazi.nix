{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    package = pkgs.unstable.yazi;

    enableZshIntegration = true;
    shellWrapperName = "y";
  };
}
