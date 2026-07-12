{den, ...}: {
  den.aspects.services.fcitx5 = {
    nixos = {pkgs, ...}: {
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";

        fcitx5 = {
          addons = [pkgs.unstable.fcitx5-bamboo];

          waylandFrontend = true;
          # ignoreUserConfig = true; # ignore `~/.config/fcitx5`

          settings = {
            addons = {
              classicui.globalSection = {
                Theme = "stylix";
              };
            };
            globalOptions = {
              "Hotkey/TriggerKeys"."0" = "Super+space";

              Behavior = {
                ShowInputMethodInformation = false;
                showInputMethodInformationWhenFocusIn = false;
                ShowFirstInputMethodInformation = false;
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
      };
    };
  };
}
