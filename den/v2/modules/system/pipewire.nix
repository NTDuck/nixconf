{
  flake.modules.nixos.pipewire = {
    pkgs,
    config,
    lib,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    services.pulseaudio.enable = false;
  };
}
