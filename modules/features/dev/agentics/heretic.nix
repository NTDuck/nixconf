{...}: {
  den.aspects.dev.agentics.heretic = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.python3Packages.heretic-llm
      ];
    };
  };
}
