{
  flake.modules.nixos.fcitx5 = {
    pkgs,
    config,
    lib,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";

      fcitx5 = {
        addons = [pkgs.unstable.fcitx5-bamboo];

        waylandFrontend = true;
        ignoreUserConfig = true; # ignore `~/.config/fcitx5`

        settings = {
          addons = {
            classicui.globalSection = {
              Theme = "stylix";
              ShowInputMethodInformation = "True";
              EnableInputMethodInformation = "True";
            };
            bamboo.globalSection = {
              InputMode = "1";
              Underline = "False";
            };
          };
          globalOptions = {
            "Hotkey/TriggerKeys" = {
              "0" = "Super+space";
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
  };
}
