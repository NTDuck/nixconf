{ den, inputs, ... }: {
  den.aspects.cloudflareWarp = {
    nixos = {pkgs, ...}: {
      services.cloudflare-warp = {
        enable = true;
        package = pkgs.unstable.cloudflare-warp;

        openFirewall = true;
      };
    };
  };
}
