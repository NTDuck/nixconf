{den, ...}: {
  den.aspects.utilities.p7zip = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.unstable.p7zip];
    };
  };
}
