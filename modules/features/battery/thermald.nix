{den, ...}: {
  den.aspects.battery.thermald = {
    nixos = {pkgs, ...}: {
      services.thermald = {
        enable = true;
        package = pkgs.unstable.thermald;
      };
    };
  };
}
