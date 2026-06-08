{
  flake.modules.nixos.alejandra = {
    pkgs,
    config,
    lib,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    environment.systemPackages = [
      pkgs.unstable.alejandra
    ];
  };
}
