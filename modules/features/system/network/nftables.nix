{den, ...}: {
  den.aspects.services.nftables = {
    nixos = {
      networking.nftables.enable = true;
    };
  };
}
