{den, ...}: {
  den.aspects.rufus = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.unstable.impression];};
  };
}
