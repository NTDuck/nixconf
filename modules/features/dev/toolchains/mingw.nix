{den, ...}: {
  den.aspects.mingw = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.unstable.mingw-w64];};
  };
}
