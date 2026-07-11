{den, ...}: {
  den.aspects.services.xdg = {
    nixos = {pkgs, ...}: let
      wlrootsPortal = {
        default = ["gtk"];

        "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
      };
    in {
      xdg.portal = {
        enable = true;
        wlr.enable = true;

        extraPortals = [
          pkgs.unstable.xdg-desktop-portal-gtk
        ];

        config = {
          common = wlrootsPortal;
          mango = wlrootsPortal;
        };
      };
    };
  };
}
