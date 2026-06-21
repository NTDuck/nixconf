{den, ...}: {
  den.aspects.git-xet = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.git-xet
      ];
    };
  };
}
