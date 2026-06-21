{den, ...}: {
  den.aspects.telegram = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.unstable.telegram-desktop];};
  };
}
