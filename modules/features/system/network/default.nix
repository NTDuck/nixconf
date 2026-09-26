{den, ...}: {
  den.aspects.system.network = {
    includes = [
      den.aspects.system.network.cloudflare-warp
      den.aspects.system.network.nftables
      den.aspects.system.network.resolved
      den.aspects.system.network.ssh
      den.aspects.system.network.tailscale
      den.aspects.system.network.wait-online
    ];
  };
}
