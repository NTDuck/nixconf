{
  flake.modules.nixos.cachyos-kernel = {
    pkgs,
    config,
    lib,
    inputs, ...
  }: {
    imports = [inputs.chaotic.nixosModules.default];
    boot.kernelPackages = pkgs.linuxPackages_cachyos;
  };
}
