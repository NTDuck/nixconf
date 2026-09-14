{den, ...}: {
  den.aspects.dev.iac.terraform = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.terraform
        pkgs.unstable.tenv
      ];
    };
  };
}
