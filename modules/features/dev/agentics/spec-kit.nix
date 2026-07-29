{den, ...}: {
  den.aspects.dev.agentics.spec-kit = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.spec-kit
      ];
    };
  };
}
