{den, ...}: {
  # openspec: AI-native system for spec-driven development (Fission-AI/OpenSpec).
  den.aspects.dev.agentics.openspec = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.openspec
      ];
    };
  };
}
