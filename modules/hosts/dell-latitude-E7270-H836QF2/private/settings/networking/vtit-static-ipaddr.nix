{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    nixos = {pkgs, ...}: let
      nic = "enp0s31f6";
    in {
      # DELL→legion hotspot connect: nmcli device wifi connect 'Hotto Doggo'
      #   password '20041889' (2.4GHz ch6 WPA2). DNS served by hotspot
      #   gateway 192.168.12.1 after the 2026-09-17 fix.
      # Mirror of Legion's eth-vtit shell aliases with the DELL static IP .60 (Legion owns .59).
      # The declarative networking.networkmanager.ensureProfiles variant was abandoned upstream
      # (see the commented block in the Legion file); imperative nmcli aliases kept per that decision.
      environment.shellAliases = {
        eth-vtit-up = ''
          ip link show "${nic}" >/dev/null 2>&1 || { echo "eth-vtit: ${nic} missing" >&2; return 1; }

          ${pkgs.networkmanager}/bin/nmcli connection add \
            type ethernet \
            con-name "ETH_VTIT_10.224.220.60" \
            ifname "${nic}" \
            autoconnect yes \
            connection.autoconnect-priority 100 \
            ip4 10.224.220.60/24 \
            gw4 10.224.220.1 \
            ipv4.dns "10.10.101.212 10.10.101.211" \
            ipv4.method manual \
            ipv6.method auto \
            proxy.method auto \
            proxy.pac-url "http://10.10.101.208/proxy.pac"

            ${pkgs.networkmanager}/bin/nmcli connection up \
              "ETH_VTIT_10.224.220.60" \
              ifname "${nic}"
        '';

        eth-vtit-down = ''
          ip link show "${nic}" >/dev/null 2>&1 || { echo "eth-vtit: ${nic} missing" >&2; return 1; }

          ${pkgs.networkmanager}/bin/nmcli connection delete ETH_VTIT_10.224.220.60
        '';
      };
    };
  };
}
