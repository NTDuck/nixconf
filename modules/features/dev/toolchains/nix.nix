{den, ...}: {
  den.aspects.dev.toolchains.nix = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.nil
        pkgs.unstable.nixd

        pkgs.unstable.alejandra
      ];
    };
  };
}
