{
  den,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {pkgs, ...}: {
      # Declarative NM profile attempt was abandoned ("doesn't work as
      # intended", never root-caused — see dell's vtit.nix for the same
      # decision); imperative aliases kept knowingly. DELL carries a
      # verbatim twin of this alias pair with only the NIC name differing
      # (enp0s31f6) — keep the two in sync or fold into a shared module.
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
