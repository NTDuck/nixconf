{
  den,
  inputs,
  ...
}: {
  den.aspects.pearDesktop = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.pear-desktop
      ];
    };
  };
}
