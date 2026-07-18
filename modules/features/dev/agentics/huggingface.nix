{den, ...}: {
  den.aspects.dev.agentics.huggingface = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.python313Packages.huggingface-hub
      ];
    };
  };
}
