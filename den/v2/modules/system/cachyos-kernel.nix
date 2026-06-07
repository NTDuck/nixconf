{
  inputs,
  config,
  ...
}: {
  flake.modules.nixos.cachyos-kernel = {
    pkgs,
    config,
    lib,
    ...
  }: {
    imports = [inputs.chaotic.nixosModules.default];
    boot.kernelPackages = pkgs.linuxPackages_cachyos;
  };
}
