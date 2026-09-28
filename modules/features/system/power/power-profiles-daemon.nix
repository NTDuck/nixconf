{den, ...}: {
  den.aspects.system.power.power-profiles-daemon = {
    nixos = {pkgs, ...}: {
      services.power-profiles-daemon = {
        enable = true;
        package = pkgs.unstable.power-profiles-daemon;
      };
    };
  };
}
