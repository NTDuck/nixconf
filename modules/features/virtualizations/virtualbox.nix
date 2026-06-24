{den, ...}: {
  den.aspects.virtualisation.virtualbox = {
    nixos = {pkgs, ...}: {
      virtualisation.virtualbox.host = {
        enable = true;
        package = pkgs.unstable.virtualbox;
      };
    };
  };
}
