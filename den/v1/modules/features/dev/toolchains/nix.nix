{
  den.aspects.dev-toolchains = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.nil
        pkgs.unstable.nixd
      ];
    };
  };
}
