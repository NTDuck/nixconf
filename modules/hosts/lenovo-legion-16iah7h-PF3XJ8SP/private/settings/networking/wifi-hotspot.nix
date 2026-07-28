# TODO Working?
{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = let
      name = "Hotto Doggo";
      password = "20041889";

      wifiInterface = "wlp0s20f3";
      internetInterface = "enp49s0";
    in {
      # services.create_ap = {
      #   enable = true;

      #   settings = {
      #     # https://nixos.wiki/wiki/Internet_Connection_Sharing
      #     # Check hardware interface names via:
      #     # ```
      #     # $ nix shell nixpkgs#net-tools
      #     # $ ifconfig
      #     # ```

      #     # Physical interfaces:
      #     #   ip -brief link
      #     WIFI_IFACE = wifiInterface;
      #     INTERNET_IFACE = internetInterface;

      #     SSID = name;
      #     PASSPHRASE = password;

      #     # Use the Wi-Fi interface directly. This avoids the ap0 virtual
      #     # interface that previously encountered RF-kill/driver problems.
      #     NO_VIRT = 1;

      #     # WPA2-Personal.
      #     WPA_VERSION = 2;
      #     USE_PSK = 0;

      #     # 2.4 GHz compatibility profile.
      #     COUNTRY = "VN";
      #     FREQ_BAND = "2.4";
      #     CHANNEL = 6;

      #     # Start without HT/VHT/HE extensions while troubleshooting.
      #     IEEE80211N = 0;
      #     IEEE80211AC = 0;
      #     IEEE80211AX = 0;
      #     HT_CAPAB = "";
      #     VHT_CAPAB = "";

      #     DRIVER = "nl80211";

      #     # Hotspot addressing, DHCP, and DNS.
      #     GATEWAY = "192.168.12.1";
      #     DHCP_DNS = "gateway";
      #     DHCP_HOSTS = "";
      #     ETC_HOSTS = 0;
      #     NO_DNS = 0;
      #     NO_DNSMASQ = 0;

      #     # Share enp49s0 through NAT.
      #     SHARE_METHOD = "nat";

      #     # Access-point behavior.
      #     HIDDEN = 0;
      #     ISOLATE_CLIENTS = 0;

      #     MAC_FILTER = 0;
      #     MAC_FILTER_ACCEPT = "/etc/hostapd/hostapd.accept";

      #     # Do not change the interface MAC address.
      #     NEW_MACADDR = "";

      #     # systemd manages the process lifecycle.
      #     DAEMONIZE = 0;

      #     # Avoid invoking the optional haveged helper.
      #     NO_HAVEGED = 1;
      #   };
      # };

      # # dnsmasq serves DHCP and DNS on the hotspot interface.
      # networking.firewall.interfaces.${wifiInterface} = {
      #   allowedUDPPorts = [
      #     53 # DNS
      #     67 # DHCP server
      #   ];

      #   allowedTCPPorts = [
      #     53 # DNS
      #   ];
      # };

      # # Avoid starting create_ap before NetworkManager has initialized the
      # # physical devices. create_ap will mark the AP interface unmanaged.
      # systemd.services.create_ap = {
      #   wants = ["NetworkManager.service"];
      #   after = ["NetworkManager.service"];
      # };
    };
  };
}
