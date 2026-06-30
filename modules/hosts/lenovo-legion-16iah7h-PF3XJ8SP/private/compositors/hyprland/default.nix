{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.provides.to-users = {user, ...}: {
    nixos = {pkgs, ...}: {
      # Somehow usable for mangowm ?
      environment.sessionVariables = {
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        LIBVA_DRIVER_NAME = "nvidia";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        NIXOS_OZONE_WL = "1";

        # # Scale factor for GTK 3 & 4 apps (e.g., Zen Browser, Firefox, Nautilus)
        # # 1.25 or 1.5 is usually ideal for 2560x1600 screens
        # GDK_SCALE = "1.5";

        # # Stops GTK from undoing the scale on high-DPI displays
        # GDK_DPI_SCALE = "1";

        # # # Scale factor for Qt apps (e.g., VLC, KeepassXC)
        # QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        # QT_SCALE_FACTOR = "1.5";
      };

      # environment.systemPackages = [
      #   pkgs.unstable.xorg.xwayland
      # ];
    };
  };
}
