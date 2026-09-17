{den, ...}: {
  den.aspects.desktop.portals.xdg = {internalOutput ? "eDP-1"}: {
    nixos = {pkgs, ...}: let
      # Mango is a wlroots compositor, so screen capture goes through
      # xdg-desktop-portal-wlr while generic dialogs still fall back to GTK.
      wlrootsPortal = {
        default = ["gtk"];

        "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
      };
    in {
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];

        wlr = {
          enable = true;
          settings.screencast = {
            chooser_type = "none";
            # Host-provided: the panel that screencast should capture when a
            # chooser is suppressed.
            output_name = internalOutput;
          };
        };

        config = {
          common = wlrootsPortal;
          mango = wlrootsPortal;
        };
      };
    };
  };
}
