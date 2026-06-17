{den, ...}: {
  den.aspects.virtualbox = {
    nixos = {pkgs, ...}: {virtualisation.virtualbox.host.enable = true;};
  };
}
