{
  den,
  inputs,
  ...
}: {
  den.aspects.nix = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.nil
        pkgs.unstable.nixd
      ];
    };
  };
}
