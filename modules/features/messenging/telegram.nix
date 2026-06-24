{
  den,
  inputs,
  ...
}: {
  den.aspects.messenging.telegram = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.ayugram.packages.${pkgs.stdenv.hostPlatform.system}.ayugram-desktop
      ];
    };
  };
}
