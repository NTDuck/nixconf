{den, ...}: {
  den.aspects.docker = {
    nixos = {pkgs, ...}: {
      virtualisation.docker.enable = true;
      environment.systemPackages = [pkgs.unstable.docker-compose];
    };
  };
}
