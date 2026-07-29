{den, ...}: {
  den.aspects.services.pipewire = {
    nixos = {pkgs, ...}: {
      services.pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        wireplumber.enable = true;
      };

      security.rtkit.enable = true;
      services.pulseaudio.enable = false;
    };
  };
}
