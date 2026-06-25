{den, ...}: {
  den.aspects.utilities.rufus = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.unstable.impression];};
  };
}
