{den, ...}: {
  den.aspects.virtualization.docker = {
    nixos = {pkgs, ...}: {
      virtualisation.docker.enable = true;
      environment.systemPackages = [pkgs.unstable.docker-compose];
    };
  };
}
