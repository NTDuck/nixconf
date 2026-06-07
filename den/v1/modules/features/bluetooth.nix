{inputs, ...}: {
  flake.modules.nixos.bluetooth = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = false;

    environment.systemPackages = [
      pkgs.bluetui
    ];
  };
}
