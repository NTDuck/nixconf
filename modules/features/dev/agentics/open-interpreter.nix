{den, ...}: {
  den.aspects.dev.agentics.open-interpreter = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.open-interpreter
      ];
    };
  };
}
