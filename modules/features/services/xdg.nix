{den, ...}: {
  den.aspects.services.xdg = {
    nixos = {
      lib,
      pkgs,
      ...
    }: let
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
