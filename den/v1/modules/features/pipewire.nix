{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.nixos.pipewire = {

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
