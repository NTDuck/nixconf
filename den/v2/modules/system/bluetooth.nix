{
  flake.modules.nixos.bluetooth = {
    pkgs,
    config,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
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
