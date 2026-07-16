{den, ...}: {
  den.aspects.services.xdg = {
    nixos = {
      lib,
      pkgs,
      ...
    }: let
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
        extraPortals = lib.mkForce [
          pkgs.xdg-desktop-portal-wlr
          pkgs.xdg-desktop-portal-gtk
        ];

        config = {
          common = wlrootsPortal;
          mango = wlrootsPortal;
        };
      };
    };
  };
}
