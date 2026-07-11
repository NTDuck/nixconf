{den, ...}: {
  den.aspects.productivity.notion = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.notion-app-enhanced
      ];
    };
  };
}
