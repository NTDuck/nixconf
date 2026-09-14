{den, ...}: {
  den.aspects.apps.productivity.mermaid = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.mermaid-cli
      ];
    };
  };
}
