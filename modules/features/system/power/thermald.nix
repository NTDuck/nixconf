{den, ...}: {
  den.aspects.system.power.thermald = {
    nixos = {pkgs, ...}: {
      services.thermald = {
        enable = true;
        package = pkgs.unstable.thermald;
      };
    };
  };
}
