{
  den,
  inputs,
  ...
}: {
  den.aspects."cachyos-kernel" = {
    nixos = {pkgs, ...}: {
      nixpkgs.overlays = [inputs.cachyos-kernel.overlays.pinned];
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
    };
  };
}
