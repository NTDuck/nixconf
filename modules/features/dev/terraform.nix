{den, ...}: {
  den.aspects.dev.terraform = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.terraform
      ];
    };
  };
}
