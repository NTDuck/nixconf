{ pkgs, ... }:

{
  wayland.windowManager.river = {
    enable = true;

    # https://mynixos.com/home-manager/option/wayland.windowManager.river.settings
    # https://github.com/completely-normal-dude/completely-normal-dotfiles/blob/old-nordic-dotfiles/river/init
    settings = {
      map.normal = {
        "Super Return" = "spawn footclient";
        "Super D" = "spawn '${pkgs.bemenu}/bin/bemenu-run'";

        # Vim keymaps?
        "Super J" = "focus-view next";
        "Super K" = "focus-view previous";

        "Super+Shift J" = "swap next";
        "Super+Shift K" = "swap previous";

        "Super F" = "toggle-fullscreen";

        # Hardware
        "None XF86AudioRaiseVolume" = "spawn 'pamixer -i 5'";
        "None XF86AudioLowerVolume" = "spawn 'pamixer -d 5'";
        "None XF86AudioMute" = "spawn 'pamixer --toggle-mute'";

        "None XF86MonBrightnessUp" = "spawn 'brightnessctl set +5%'";
        "None XF86MonBrightnessDown" = "spawn 'brightnessctl set 5%-'";

        # Workspaces
        "Super 1" = "set-focused-tags 1";
        "Super 2" = "set-focused-tags 2";
        "Super 3" = "set-focused-tags 4";
        "Super 4" = "set-focused-tags 8";
        "Super 5" = "set-focused-tags 16";
        "Super 6" = "set-focused-tags 32";
        "Super 7" = "set-focused-tags 64";
        "Super 8" = "set-focused-tags 128";
        "Super 9" = "set-focused-tags 256";

        "Super+Shift 1" = "set-view-tags 1";
        "Super+Shift 2" = "set-view-tags 2";
        "Super+Shift 3" = "set-view-tags 4";
        "Super+Shift 4" = "set-view-tags 8";
        "Super+Shift 5" = "set-view-tags 16";
        "Super+Shift 6" = "set-view-tags 32";
        "Super+Shift 7" = "set-view-tags 64";
        "Super+Shift 8" = "set-view-tags 128";
        "Super+Shift 9" = "set-view-tags 256";

        "Super Q" = "close";
        "Super Shift E" = "exit";
      };

      map-pointer.normal = {
        "Super BTN_LEFT" = "move view";
        "Super BTN_RIGHT" = "move view";
        "Super BTN_MIDDLE" = "toggle-float";
      };
    };

    # extraConfig = ''
    #   rivertile -view-padding 4 -outer-padding 4 &
    #   yambar &
    #   riverctl background-color 0x111111 &
    #   riverctl spawn "${pkgs.fcitx5}/bin/fcitx5 -d --replace"
    # '';

    extraConfig = ''
      rivertile -view-padding 4 -outer-padding 4 -main-ratio 0.5 &
      waybar &
      riverctl spawn "${pkgs.fcitx5}/bin/fcitx5 -d --replace"
    '';
  };

  home.packages = [
    pkgs.brightnessctl
    pkgs.pamixer
  ];
}
