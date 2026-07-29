{den, ...}: {
  den.aspects.productivity.mermaid = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.mermaid-cli
      ];
    };
  };
}
