{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {pkgs, ...}: {
      # networking.networkmanager.ensureProfiles.profiles = {
      #   "ETH_VTIT_10.224.220.59" = {
      #     connection = {
      #       id = "ETH_VTIT_10.224.220.59";
      #       type = "ethernet";
      #       interface-name = "enp49s0";
      #       autoconnect = true;
      #       autoconnect-priority = 100;
      #     };

      #     ipv4 = {
      #       method = "manual";
      #       address1 = "10.224.220.59/24";
      #       gateway = "10.224.220.1";
      #       dns = "10.10.101.212;10.10.101.211";
      #     };

      #     ipv6.method = "auto";

      #     proxy = {
      #       method = "auto";
      #       pac-url = "http://10.10.101.208/proxy.pac";
      #     };
      #   };
      # };

      # Apparently the above doesn't work as intended
      environment.shellAliases = {
        eth-vtit-up = ''
          ${pkgs.networkmanager}/bin/nmcli connection add \
            type ethernet \
            con-name "ETH_VTIT_10.224.220.59" \
            ifname enp49s0 \
            autoconnect yes \
            connection.autoconnect-priority 100 \
            ip4 10.224.220.59/24 \
            gw4 10.224.220.1 \
            ipv4.dns "10.10.101.212 10.10.101.211" \
            ipv4.method manual \
            ipv6.method auto \
            proxy.method auto \
            proxy.pac-url "http://10.10.101.208/proxy.pac"

            ${pkgs.networkmanager}/bin/nmcli connection up \
              "ETH_VTIT_10.224.220.59" \
              ifname enp49s0
        '';

        eth-vtit-down = "${pkgs.networkmanager}/bin/nmcli connection delete ETH_VTIT_10.224.220.59";
      };
    };
  };
}
