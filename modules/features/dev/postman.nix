{den, ...}: {
  den.aspects.dev.postman = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.postman
      ];
    };
  };
}
