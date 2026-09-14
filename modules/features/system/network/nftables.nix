{den, ...}: {
  den.aspects.system.network.nftables = {
    nixos = {
      networking.nftables.enable = true;
    };
  };
}
