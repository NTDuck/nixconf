{den, ...}: {
  den.aspects.steam = {
    nixos = {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };

      hardware.graphics.enable32Bit = true;
    };
  };
}
