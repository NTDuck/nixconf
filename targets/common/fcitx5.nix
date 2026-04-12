{pkgs, ...}: {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      addons = [
        pkgs.unstable.fcitx5-bamboo
        pkgs.unstable.fcitx5-gtk
        pkgs.unstable.qt6Packages.fcitx5-configtool
      ];

      waylandFrontend = true;
      ignoreUserConfig = true; # ignore `~/.config/fcitx5`

      settings = {
        addons = {
          classicui.globalSection = {
            ShowInputMethodInformation = "False";
            EnableInputMethodInformation = "False";
            ShowInputMethodInformationIfOnlyOneInputMethod = "False";
            ShowInputMethodInformationInApp = "False";
            showInputMethodInformationWhenFocusIn = "False";
            Theme = "stylix";
          };
          notification.globalSection = {
            ShowInputMethodInformation = "False";
          };
          bamboo.globalSection = {
            InputMode = "1";
            Underline = "False";
            ShowModeIndicator = "False";
            ShowSwitchTip = "False";
          };
        };
        globalOptions = {
          "Hotkey/TriggerKeys" = {
            "0" = "Super+space";
            # "1" = "Control+Shift_L";
            # "2" = "Control+Shift_R";
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
