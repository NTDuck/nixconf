{
  flake.modules.nixos.cachyos-kernel = {
    pkgs,
    inputs,
    ...
  }: {
    nixpkgs.overlays = [inputs.cachyos-kernel.overlays.pinned];
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  };
}
