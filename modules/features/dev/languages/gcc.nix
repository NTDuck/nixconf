{den, ...}: {
  den.aspects.gcc = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.gcc];};
  };
}
