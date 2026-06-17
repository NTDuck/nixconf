{den, ...}: {
  den.aspects.mingw = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.mingw-w64];};
  };
}
