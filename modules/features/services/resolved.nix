{den, ...}: {
  den.aspects.services.resolved = {
    nixos = {
      services.resolved = {
        enable = true;

        settings.Resolve = {
          DNSOverTLS = true;
        };
      };
    };
  };
}
