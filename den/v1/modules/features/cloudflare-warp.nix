{inputs, ...}: {
  flake.modules.nixos.cloudflare-warp = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    services.cloudflare-warp.enable = true;
  };
}
