{den, ...}: {
  den.aspects.dev.agentics.lmstudio = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.lmstudio
      ];
    };
  };
}
