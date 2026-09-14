{den, ...}: {
  den.aspects.dev.api.postman = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.postman
      ];
    };
  };
}
