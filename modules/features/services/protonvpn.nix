{den, ...}: {
  den.aspects.protonvpn = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.unstable.protonvpn-gui];};
  };
}
