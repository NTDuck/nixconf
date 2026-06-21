{den, ...}: {
  den.aspects.vortex = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.bottles
        pkgs.unstable.bottles-unwrapped
      ];
    };
  };
}
