{den, ...}: {
  den.aspects.settings.networking = {
    includes = [
      den.aspects.services.resolved
    ];

    nixos = {
      networking = {
        networkmanager = {
          enable = true;
          dns = "systemd-resolved";
        };
        nameservers = ["8.8.8.8" "1.1.1.1"];
      };

      services.create_ap = {
        enable = true;
        settings = {
          INTERNET_IFACE = "enp49s0";
          WIFI_IFACE = "wlp0s20f3";
          SSID = "Hotto Doggo";
          PASSPHRASE = "20041889";
        };
      };
    };
  };
}
