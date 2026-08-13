{...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      networking = {
        interfaces.enp49s0 = {
          ipv4.addresses = [
            {
              address = "10.224.220.59";
              prefixLength = 24;
            }
          ];
        };

        networkmanager.ensureProfiles.profiles = {
          "Company-Ethernet" = {
            connection = {
              id = "Company Ethernet";
              type = "ethernet";
              interface-name = "enp49s0";
              autoconnect = "true";
            };
            ipv4 = {
              method = "manual";
              address1 = "10.224.220.59/24";
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
