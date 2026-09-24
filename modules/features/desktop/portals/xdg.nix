# wlr (default true): wire the wlroots ScreenCast/Screenshot backend
# (xdg-desktop-portal-wlr). Wayland compositors (mango, labwc) pass the
# default; X11 sessions (dell spectrwm) pass wlr = false — the wlr portal
# is Wayland-only and inert there, and the GTK portal covers Screenshot
# on X11 (ScreenCast simply has no X11 backend).
{
  ...
}: {
  den.aspects.desktop.portals.xdg = {
    internalOutput ? "eDP-1",
    wlr ? true,
  }: {
    nixos = {pkgs, ...}: let
      # Mango is a wlroots compositor, so screen capture goes through
      # xdg-desktop-portal-wlr while generic dialogs still fall back to GTK.
      wlrPortal = {
        default = ["gtk"];

        "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
      };
      # X11: no wlr backend; GTK handles Screenshot (and everything else
      # falls back to its default).
      gtkPortal = {
        default = ["gtk"];

        "org.freedesktop.impl.portal.Screenshot" = ["gtk"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
      };
      portal = if wlr then wlrPortal else gtkPortal;
    in {
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];

        wlr = {
          enable = wlr;
          settings.screencast = {
            chooser_type = "none";
            # Host-provided: the panel that screencast should capture when a
            # chooser is suppressed.
            output_name = internalOutput;
          };
        };

        config = {
          common = portal;
          mango = portal;
        };
      };
    };
  };
}
