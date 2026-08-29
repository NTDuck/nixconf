{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {pkgs, ...}: {
      # https://wiki.nixos.org/wiki/Thunderbolt
      services.hardware.bolt = {
        enable = true;
        package = pkgs.bolt;
      };
    };
  };
}
