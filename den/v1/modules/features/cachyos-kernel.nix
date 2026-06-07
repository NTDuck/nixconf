{inputs, ...}: {
  flake.modules.nixos.cachyos-kernel = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    nixpkgs.overlays = [inputs.cachyos-kernel.overlays.pinned];
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  };
}
