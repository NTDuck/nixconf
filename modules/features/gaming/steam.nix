{den, ...}: {
  den.aspects.gaming.steam = {
    nixos = {
      lib,
      pkgs,
      ...
    }: let
      mangohud-enabled = den.aspects.services.gnome-keyring.enable or false;
    in {
      programs.steam = {
        enable = true;

        package = pkgs.unstable.steam.override {
          extraEnv =
            {
              # OBS_VKCAPTURE = true;
              # RADV_TEX_ANISO = 16;
            }
            // lib.optionalAttrs mangohud-enabled {MANGOHUD = true;};
        };

        extraCompatPackages = [
          pkgs.unstable.proton-ge-bin
        ];

        extest.enable = true;

        protontricks = {
          enable = true;
          package = pkgs.unstable.protontricks;
        };

        # remotePlay.openFirewall = true;
        # dedicatedServer.openFirewall = true;
        # localNetworkGameTransfers.openFirewall = true;
      };

      hardware.graphics.enable32Bit = true;
    };
  };
}
