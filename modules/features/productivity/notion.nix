{den, ...}: {
  den.aspects.office.notion = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.notion-app-enhanced
      ];
    };
  };
}
