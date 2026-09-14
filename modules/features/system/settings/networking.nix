{den, ...}: {
  den.aspects.system.settings.networking = {
    includes = [
      den.aspects.system.network.resolved
    ];

    nixos = {
      networking = {
        networkmanager = {
          enable = true;
          dns = "systemd-resolved";
        };
        nameservers = ["8.8.8.8" "1.1.1.1"];
      };
    };
  };
}
