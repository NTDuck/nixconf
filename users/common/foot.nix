{ lib, ... }:

{
  programs.foot = {
    enable = true;
    server.enable = true;

    # https://man.archlinux.org/man/foot.ini.5.en
    # https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
    settings = {
      main = {
        pad = "15x15";
        gamma-correct-blending = "no";
        term = "xterm-256color";
      };

      colors = {
        alpha = lib.mkForce "0.8";
      };

      mouse = {
        hide-when-typing = "yes";
        alternate-scroll-mode = "yes";
      };
    };
  };
}
