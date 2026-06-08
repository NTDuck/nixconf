{
  flake.modules.nixos.cloudflare-warp = {config, ...}: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    services.cloudflare-warp.enable = true;
  };
}
