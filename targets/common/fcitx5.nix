{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      addons = [ pkgs.fcitx5-bamboo ];
      #   addons = [
      #     pkgs.fcitx5-bamboo
      #     pkgs.fcitx5-gtk
      #     pkgs.kdePackages.fcitx5-qt
      #   ];

      waylandFrontend = true;
      ignoreUserConfig = true;  # ignore `~/.config/fcitx5`
      
      settings.inputMethod = {
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          DefaultIM = "bamboo";
        };
        "Groups/0/Items/0".Name = "keyboard-us";
        "Groups/0/Items/1".Name = "bamboo";
        GroupOrder."0" = "Default";
      };
    };
  };

  environment.sessionVariables = {
    XMODIFIERS = "@im=fcitx";
    QT_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "fcitx";
  };
}
