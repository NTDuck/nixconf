{den, ...}: {
  den.aspects.battery.thermald = {
    nixos = {
      services.thermald = {pkgs, ...}: {
        enable = true;
        package = pkgs.unstable.thermald;
      };
    };
  };
}
