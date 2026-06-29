{den, ...}: {
  den.aspects.services.xdg = {
    nixos = {pkgs, ...}: {
      xdg.portal = {
        enable = true;
        wlr.enable = true; # Enables `xdg-desktop-portal-wlr`

        extraPortals = [
          pkgs.unstable.xdg-desktop-portal-gtk
        ];

        # config = {
        #   common = {
        #     default = ["wlr" "gtk"];
        #   };
        # };
      };

      environment.systemPackages = [
        pkgs.unstable.xdg-utils
      ];
    };

    homeManager = {
      xdg = {
        enable = true;
        userDirs.enable = true;
      };
    };
  };
}
