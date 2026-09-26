# WiFi hotspot (Hotto Doggo) — DEFAULT GENERATION (2026-09-26 user
# decision: the homelab specialisation is for 3090-coupled config ONLY;
# a hotspot is a networking feature, not GPU-coupled). Previously gated
# behind specialisation.homelab (7e770c4) — undoing that part.
#
# AUTOSTART + WIFI-KILL GUARD: the create_ap module default is
# wantedBy multi-user.target, so the hotspot now autostarts in EVERY
# generation. That reintroduces the 2026-09-21 wifi-kill hazard
# (c424e66): hotspot and client wifi share the only radio (wlp0s20f3),
# and an undocked boot has the station up — create_ap would set the
# interface unmanaged and deauth the client link (DEAUTH_LEAVING,
# journal 2026-09-21 15:30:59; five live activations, five dead
# uplinks, five forced reboots). The preStart gate refuses to start
# unless the ethernet uplink (enp49s0, dock-only) has carrier, so
# undocked boots/activations stay on station wifi; docked boots bring
# the hotspot up automatically. restartIfChanged = false: a docked
# activation must not bounce the AP mid-use; manual restart is the
# recovery path.
{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = let
      name = "Hotto Doggo";
      password = "20041889";

      wifiInterface = "wlp0s20f3";
      internetInterface = "enp49s0";
    in {
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
          HT_CAPAB = "";
          VHT_CAPAB = "";

          DRIVER = "nl80211";

          # Hotspot addressing, DHCP, and DNS.
          GATEWAY = "192.168.12.1";
          DHCP_DNS = "1.1.1.1,8.8.8.8";
          DHCP_HOSTS = "";
          ETC_HOSTS = 0;
          NO_DNS = 1;
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

      # dnsmasq serves DHCP and DNS on the hotspot interface.
      networking.firewall.interfaces.${wifiInterface} = {
        allowedUDPPorts = [
          53 # DNS
          67 # DHCP server
        ];

        allowedTCPPorts = [
          53 # DNS
        ];
      };

      # Avoid starting create_ap before NetworkManager has initialized the
      # physical devices. create_ap will mark the AP interface unmanaged.
      systemd.services.create_ap = {
        wants = ["NetworkManager.service"];
        after = ["NetworkManager.service"];
        # Dock gate — see the file header for the wifi-kill history.
        preStart = ''
          if ! cat /sys/class/net/enp49s0/carrier 2>/dev/null | grep -q 1; then
            echo "create_ap: undocked (enp49s0 no carrier) — refusing to grab wlp0s20f3; client wifi stays up"
            exit 1
          fi
        '';
        restartIfChanged = false;
      };
    };
  };
}
