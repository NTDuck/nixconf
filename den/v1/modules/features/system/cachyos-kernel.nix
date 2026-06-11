{ den, inputs, ... }:
{
  den.aspects."cachyos-kernel" = {
    nixos = {
    pkgs,
    inputs,
    ...
  }: {
    nixpkgs.overlays = [inputs.cachyos-kernel.overlays.pinned];
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  };
  };
}
