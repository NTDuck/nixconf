{
  flake.modules.nixos.alejandra = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.unstable.alejandra
    ];
  };
}
