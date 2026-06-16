{den, ...}: {
  den.aspects.system-network = {
    nixos = {
      networking = {
        networkmanager = {
          enable = true;
          dns = "systemd-resolved";
        };
        nameservers = ["8.8.8.8" "1.1.1.1"];
      };
      services.resolved.enable = true;
    };
  };
}
