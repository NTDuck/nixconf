{den, ...}: {
  den.aspects.llvm = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.unstable.llvm];};
  };
}
