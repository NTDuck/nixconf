{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = let
      name = "Hotto Doggo";
      password = "20041889";

      wifiInterface = "wlp0s20f3";
      internetInterface = "enp49s0";
    in {
      specialisation.homelab.configuration = {
        services.create_ap = {
          enable = true;

          settings = {
            # https://nixos.wiki/wiki/Internet_Connection_Sharing
            # Check hardware interface names via:
            # ```
            # $ nix shell nixpkgs#net-tools
            # $ ifconfig
            # ```

            # Physical interfaces:
            #   ip -brief link
            WIFI_IFACE = wifiInterface;
            INTERNET_IFACE = internetInterface;

            SSID = name;
            PASSPHRASE = password;

            # Use the Wi-Fi interface directly. This avoids the ap0 virtual
            # interface that previously encountered RF-kill/driver problems.
            NO_VIRT = 1;

            # WPA2-Personal.
            WPA_VERSION = 2;
            USE_PSK = 0;

            # 2.4 GHz compatibility profile.
            COUNTRY = "VN";
            FREQ_BAND = "2.4";
            CHANNEL = 6;

            IEEE80211N = 1;
            IEEE80211AC = 0;
            IEEE80211AX = 0;
            HT_CAPAB = "[HT20]";
            VHT_CAPAB = "";

            DRIVER = "nl80211";
            # 2026-09-17 DELL diagnosis: with NO_DNS=1 clients were handed the
            # public resolvers (1.1.1.1/8.8.8.8) straight over DHCP, and the
            # VTIT wired uplink drops client UDP/53 to public resolvers. The
            # phone silently fell back to LTE; the DELL (no fallback) lost DNS
            # entirely. Serve DNS from dnsmasq on the gateway instead: DHCP
            # points clients at 192.168.12.1, dnsmasq forwards through the
            # host resolver (corporate DNS), and create_ap redirects client
            # :53 to its :5353 listener. DHCP_HOSTS dropped: unrecognized by
            # create_ap 4.7.2 (WARN every boot, empty anyway).
            GATEWAY = "192.168.12.1";
            DHCP_DNS = "gateway";
            ETC_HOSTS = 0;
            NO_DNS = 0;
            NO_DNSMASQ = 0;

            # Share enp49s0 through NAT.
            SHARE_METHOD = "nat";

            # Access-point behavior.
            HIDDEN = 0;
            ISOLATE_CLIENTS = 0;

            MAC_FILTER = 0;
            MAC_FILTER_ACCEPT = "/etc/hostapd/hostapd.accept";

            # Do not change the interface MAC address.
            NEW_MACADDR = "";

            # systemd manages the process lifecycle.
            DAEMONIZE = 0;

            # Avoid invoking the optional haveged helper.
            NO_HAVEGED = 1;
          };
        };

        # NixOS native NAT and forwarding for the hotspot interface.
        networking.nat = {
          enable = true;
          internalInterfaces = [wifiInterface];
          externalInterface = internetInterface;
        };

        # Loose reverse-path filtering to prevent dropped forwarded packets.
        networking.firewall.checkReversePath = "loose";

        # dnsmasq serves DHCP and DNS on the hotspot interface; create_ap
        # listens on 5353 and redirects client :53 traffic to it, so both
        # ports must pass the nftables input chain.
        networking.firewall.interfaces.${wifiInterface} = {
          allowedUDPPorts = [
            53 # DNS
            67 # DHCP server
            5353 # create_ap dnsmasq DNS listener
          ];

          allowedTCPPorts = [
            53 # DNS
            5353 # create_ap dnsmasq DNS listener
          ];
        };

        # AUTOSTART, HOMELAB SPEC ONLY (2026-09-21 user decision): the module
        # default (wantedBy multi-user.target) stands INSIDE the specialisation;
        # the default generation never defines create_ap so it never starts
        # there. That fixes the autostart scoping but NOT the wifi-kill: the
        # hotspot and the client uplink share the only wifi radio (wlp0s20f3),
        # and an undocked boot has the station on VTIT_Guest — create_ap then
        # sets the interface unmanaged and deauths the client link
        # (DEAUTH_LEAVING, journal 2026-09-21 15:30:59; five live activations,
        # five dead uplinks, five forced reboots). The dock gate below refuses
        # to start unless the ethernet uplink (enp49s0, dock-only) has a
        # cable+carrier, so undocked boots/activations stay on station wifi and
        # docked boots bring the hotspot up automatically.
        systemd.services.create_ap = {
          wants = ["NetworkManager.service"];
          after = ["NetworkManager.service"];
          # Bounded pre-start gate: docked = enp49s0 carrier up. When undocked,
          # fail fast and STAY failed (Restart "on-failure" + this gate would
          # regrab the radio every 5s otherwise; failure = wifi preserved).
          preStart = ''
            if ! cat /sys/class/net/enp49s0/carrier 2>/dev/null | grep -q 1; then
              echo "create_ap: undocked (enp49s0 no carrier) — refusing to grab wlp0s20f3; client wifi stays up"
              exit 1
            fi
          '';
          # Manual restart is the recovery path once actually docked.
          restartIfChanged = false;
        };
      };
    };
  };
}
