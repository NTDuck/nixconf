{den, ...}: {
  den.aspects.system.virtualization.waydroid = {
    includes = [
      den.aspects.system.network.nftables
    ];

    nixos = {pkgs, ...}: {
      virtualisation.waydroid = {
        enable = true;
        package = pkgs.unstable.waydroid-nftables;
      };
    };
  };
}
