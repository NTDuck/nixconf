{
  inputs,
  config,
  ...
}: let
  username = config.this.username;
  hostname = config.this.hostname;
in {
  flake.modules.nixos.bluetooth = {
    pkgs,
    config,
    lib,
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
