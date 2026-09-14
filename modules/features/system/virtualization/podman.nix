{den, ...}: {
  den.aspects.system.virtualization.podman = {
    homeManager = {pkgs, ...}: {
      services.podman = {
        enable = true;
        package = pkgs.unstable.podman;
      };
    };
  };
}
