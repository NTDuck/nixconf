{den, ...}: {
  den.aspects.cmake = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.unstable.cmake];};
  };
}
