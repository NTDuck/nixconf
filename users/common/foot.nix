{ lib, ... }:

{
  programs.foot = {
    enable = true;
    server.enable = true;

    # https://man.archlinux.org/man/foot.ini.5.en
    # https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
    settings = {
      main = {
        pad = "14x10";
        gamma-correct-blending = "no";
        term = "xterm-256color";
      };

      mouse = {
        hide-when-typing = "yes";
        alternate-scroll-mode = "yes";
      };
    };
  };
}
