{den, ...}: {
  den.aspects.spec-kit = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.spec-kit
      ];
    };
  };
}
