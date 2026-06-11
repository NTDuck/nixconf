{ den, inputs, ... }:
{
  den.aspects."pipewire" = {
    nixos = {...}: {
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
  };
}
