{den, ...}: {
  den.aspects.virtualizations.docker = {
    nixos = {
      user,
      pkgs,
      ...
    }: {
      virtualisation.docker.enable = true;
      environment.systemPackages = [pkgs.unstable.docker-compose];

      users.users.${user.name}.extraGroups = ["docker"];
    };
  };
}
