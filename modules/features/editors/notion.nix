{den, ...}: {
  den.aspects.notion = {
    nixos = {pkgs, ...}: {environment.systemPackage = [pkgs.unstable.notion-app-enhanced];};
  };
}
