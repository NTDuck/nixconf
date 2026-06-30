{den, ...}: {
  den.aspects.services.cloudflare-warp = {
    nixos = {pkgs, ...}: {
      services.cloudflare-warp = {
        enable = true;
        package = pkgs.unstable.cloudflare-warp;

        openFirewall = true;
      };
    };
  };
}
