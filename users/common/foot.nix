{ ... }:

{
  programs.foot = {
    enable = true;

    # https://man.archlinux.org/man/foot.ini.5.en
    # https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
    settings = {
      main = {
        gamma-correct-blending = "no";
        # font = "Fira Code:size=11";
        # term = "xterm-256color";
      };

      mouse = {
        hide-when-typing = "yes";
        alternate-scroll-mode = "yes";
      };
    };
  };

  catppuccin.foot.enable = true;
}
