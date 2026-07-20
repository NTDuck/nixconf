{den, ...}: {
  den.aspects.settings.networking = {
    includes = [
      den.aspects.services.resolved
    ];

    nixos = {pkgs, ...}: let
      hotspotUp = pkgs.writeShellApplication {
        name = "hotspot-up";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.gawk
          pkgs.networkmanager
        ];
        text = ''
          ssid="Hotto Doggo"
          password="20041889"
          connection="hotspot-hotto-doggo"
          ifname="''${1:-}"

          if [ -z "$ifname" ]; then
            ifname="$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2 == "wifi" { print $1; exit }')"
          fi

          if [ -z "$ifname" ]; then
            echo "No Wi-Fi device found." >&2
            exit 1
          fi

          if ! nmcli -t -f DEVICE,TYPE,STATE device | awk -F: '$2 != "wifi" && $3 == "connected" { found = 1 } END { exit !found }'; then
            echo "No connected non-Wi-Fi uplink found; refusing to turn the active Wi-Fi client into a hotspot." >&2
            exit 1
          fi

          nmcli radio wifi on
          nmcli connection delete "$connection" >/dev/null 2>&1 || true
          nmcli connection add \
            type wifi \
            ifname "$ifname" \
            con-name "$connection" \
            autoconnect no \
            ssid "$ssid"
          nmcli connection modify "$connection" \
            connection.autoconnect no \
            connection.interface-name "$ifname" \
            802-11-wireless.mode ap \
            802-11-wireless.band bg \
            802-11-wireless.channel 6 \
            802-11-wireless.hidden no \
            802-11-wireless-security.key-mgmt wpa-psk \
            802-11-wireless-security.auth-alg open \
            802-11-wireless-security.proto rsn \
            802-11-wireless-security.pairwise ccmp \
            802-11-wireless-security.group ccmp \
            802-11-wireless-security.pmf disable \
            802-11-wireless-security.psk "$password" \
            ipv4.method shared \
            ipv6.method disabled
          nmcli connection down "$connection" >/dev/null 2>&1 || true
          nmcli connection up "$connection"

          echo "Started hotspot '$ssid' on $ifname as NetworkManager connection '$connection'."
        '';
      };

      hotspotDown = pkgs.writeShellApplication {
        name = "hotspot-down";
        runtimeInputs = [
          pkgs.networkmanager
        ];
        text = ''
          connection="hotspot-hotto-doggo"
          nmcli connection down "$connection"
        '';
      };
    in {
      networking = {
        networkmanager = {
          enable = true;
          dns = "systemd-resolved";
        };
        nameservers = ["8.8.8.8" "1.1.1.1"];
      };

      environment.systemPackages = [
        hotspotUp
        hotspotDown
      ];
    };
  };
}
