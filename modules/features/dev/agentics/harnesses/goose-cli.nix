{den, ...}: {
  den.aspects.dev.agentics.goose-cli = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.goose-cli
      ];
    };
  };
}
