{
  inputs,
  config,
  ...
}: let
  username = config.this.username;
  hostname = config.this.hostname;
in {
  flake.modules.nixos.alejandra = {
    pkgs,
    config,
    lib,
    ...
  }: {
    environment.systemPackages = [
      pkgs.alejandra
    ];
  };
}
