{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.nixos.cloudflare-warp = {

  services.cloudflare-warp.enable = true;

  };
}
