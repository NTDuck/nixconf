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
    };
  };
}
