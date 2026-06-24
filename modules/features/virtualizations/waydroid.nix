{den, ...}: {
  den.aspects.virtualisation.waydroid = {
    includes = [
      den.aspects.services.nftables
    ];

    nixos = {pkgs, ...}: {
      virtualisation.waydroid = {
        enable = true;
        package = pkgs.unstable.waydroid-nftables;
      };
    };
  };
}
