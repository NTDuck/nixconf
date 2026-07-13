{den, ...}: {
  den.aspects.services.pipewire = {
    nixos = {pkgs, ...}: {
      services.pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        wireplumber.enable = true;
      };

      security.rtkit.enable = true;
      services.pulseaudio.enable = false;

      xdg.portal = {
        enable = true;
        wlr.enable = true;

        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];

        config = {
          common = {
            default = ["gtk"];
            "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
            "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
          };

          mango = {
            default = ["gtk"];
            "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
            "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
            "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          };

          sway = {
            default = ["gtk"];
            "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
            "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
            "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          };
        };
      };
    };
  };
}
