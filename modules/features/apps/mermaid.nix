{den, ...}: {
  den.aspects.apps.mermaid = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.mermaid-cli
      ];
    };
  };
}
