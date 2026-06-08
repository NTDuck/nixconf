{
  flake.modules.nixos.alejandra = {
    pkgs,
    config,
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
