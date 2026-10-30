{den, ...}: {
  den.aspects.apps.jq = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.jq
      ];
    };
  };
}
