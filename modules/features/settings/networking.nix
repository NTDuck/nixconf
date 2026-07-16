{den, ...}: {
  den.aspects.settings.networking = {
    includes = [
      den.aspects.services.resolved
    ];

    nixos = {pkgs, ...}: let
      nmHotspot = pkgs.writeShellApplication {
        name = "nm-hotspot";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.gawk
          pkgs.networkmanager
        ];
        text = ''
          ssid="''${1:-ayin-hotspot}"
          ifname="''${2:-}"
          connection="hotspot-$ssid"

          if [ -z "$ifname" ]; then
            ifname="$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2 == "wifi" { print $1; exit }')"
          fi

          if [ -z "$ifname" ]; then
            echo "No Wi-Fi device found." >&2
            exit 1
          fi

          printf "Hotspot password for %s: " "$ssid" >&2
          trap 'stty echo' EXIT
          stty -echo
          read -r password
          stty echo
          trap - EXIT
          printf '\n' >&2

          if [ "''${#password}" -lt 8 ]; then
            echo "WPA hotspot password must be at least 8 characters." >&2
            exit 1
          fi

          nmcli radio wifi on
          nmcli device wifi hotspot \
            ifname "$ifname" \
            con-name "$connection" \
            ssid "$ssid" \
            password "$password"

          nmcli connection modify "$connection" connection.autoconnect no
          echo "Started hotspot '$ssid' on $ifname as NetworkManager connection '$connection'."
        '';
      };

      nmHotspotDown = pkgs.writeShellApplication {
        name = "nm-hotspot-down";
        runtimeInputs = [
          pkgs.networkmanager
        ];
        text = ''
          connection="''${1:-hotspot-ayin-hotspot}"
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
        nmHotspot
        nmHotspotDown
      ];
    };
  };
}
