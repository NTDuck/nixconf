{den, ...}: {
  den.aspects.dev.agentics.agent-browser = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.agent-browser
      ];
    };
  };
}
