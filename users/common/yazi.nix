{ ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };

  catppuccin.yazi.enable = true;
}
