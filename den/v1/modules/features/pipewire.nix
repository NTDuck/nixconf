{inputs, ...}: {
  flake.modules.nixos.pipewire = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
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
