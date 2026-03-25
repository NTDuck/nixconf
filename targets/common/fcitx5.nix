{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      addons = [ pkgs.fcitx5-bamboo ];

      waylandFrontend = true;
      ignoreUserConfig = true; # ignore `~/.config/fcitx5`

      settings = {
        addons = {
          classicui.globalSection.ShowInputMethodInformation = "False";
          bamboo.globalSection.InputMode = "1";
        };
        globalOptions = {
          "Hotkey/TriggerKeys" = {
            "0" = "Control+Shift_L";
            "1" = "Control+Shift_R";
          };
        };
        inputMethod = {
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
  };

  environment.sessionVariables = {
    XMODIFIERS = "@im=fcitx";
    QT_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "fcitx";
  };
}
