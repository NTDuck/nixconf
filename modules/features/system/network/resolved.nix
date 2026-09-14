{den, ...}: {
  den.aspects.system.network.resolved = {
    nixos = {
      services.resolved = {
        enable = true;

        # settings.Resolve = {
        #   DNSOverTLS = true;
        # };
      };
    };
  };
}
