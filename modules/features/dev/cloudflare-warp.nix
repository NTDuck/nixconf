{
  flake.modules.nixos.cloudflare-warp = {pkgs, ...}: {
    services.cloudflare-warp = {
      enable = true;
      package = pkgs.unstable.cloudflare-warp;

      openFirewall = true;
    };
  };

  # Add aliases
}
