{
  den,
  inputs,
  ...
}: {
  den.aspects.cachyosKernel = {
    nixos = {pkgs, ...}: {
      nixpkgs.overlays = [inputs.cachyos-kernel.overlays.pinned];
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
    };
  };
}
