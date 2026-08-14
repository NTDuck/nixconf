{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      networking = {
        networkmanager.ensureProfiles.profiles = {
          "ETH_VTIT_10.224.220.59" = {
            connection = {
              id = "ETH_VTIT_10.224.220.59";
              type = "ethernet";
              interface-name = "enp49s0";
              autoconnect = "true";
            };
            ipv4 = {
              method = "manual";
              address1 = "10.224.220.59/24";
              gateway = "10.224.220.1";
            };
            ipv6 = {
              method = "auto";
            };
          };
        };
      };
    };
  };
}
