{den, ...}: {
  den.aspects.dev.gits.git-xet = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.git-xet
      ];
    };
  };
}
