{den, ...}: {
  den.aspects.services.polkit = {
    nixos = {pkgs, ...}: {
      security.polkit = {
        enable = true;
        package = pkgs.unstable.polkit;
      };
    };
  };
}
