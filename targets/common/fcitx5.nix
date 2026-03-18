{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      waylandFrontend = true;

      addons = [
        pkgs.fcitx5-bamboo
        pkgs.fcitx5-gtk
        pkgs.kdePackages.fcitx5-qt
      ];
    }
  };
}
