{
  flake.modules.nixos.pear-desktop = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.unstable.pear-desktop
    ];
  };
}
