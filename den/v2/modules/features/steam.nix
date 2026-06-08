{
  flake.modules.nixos.steam = {config, ...}: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    hardware.graphics.enable32Bit = true;
  };
}
