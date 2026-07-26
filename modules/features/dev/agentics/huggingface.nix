{den, ...}: {
  den.aspects.dev.agentics.huggingface = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.python314Packages.huggingface-hub
      ];
    };
  };
}
