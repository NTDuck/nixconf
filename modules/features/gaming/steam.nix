{den, ...}: {
  den.aspects.gaming.steam = {
    nixos = {pkgs, ...}: {
      programs.steam = {
        enable = true;
        package = pkgs.unstable.steam;

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
