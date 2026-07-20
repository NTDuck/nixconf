{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.nixos = let
    name = "Hotto Doggo";
    password = "20041889";
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
        INTERNET_IFACE = "enp49s0";
        WIFI_IFACE = "wlp0s20f3";

        SSID = name;
        PASSPHRASE = password;
      };
    };
  };
}
