{
  flake.modules.nixos.cloudflare-warp = {
    pkgs,
    config,
    lib,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    services.cloudflare-warp.enable = true;
  };
}
