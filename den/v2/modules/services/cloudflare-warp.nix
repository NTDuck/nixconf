{
  inputs,
  config,
  ...
}: let
  username = config.this.username;
  hostname = config.this.hostname;
in {
  flake.modules.nixos.cloudflare-warp = {
    pkgs,
    config,
    lib,
    ...
  }: {
    services.cloudflare-warp.enable = true;
  };
}
