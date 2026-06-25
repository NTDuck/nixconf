{den, ...}: {
  den.aspects.office.notion = {
    nixos = {pkgs, ...}: {environment.systemPackage = [pkgs.unstable.notion-app-enhanced];};
  };
}
