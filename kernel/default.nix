{ pkgs, nix-cachyos-kernel, ... }:

{
  nixpkgs.overlays = [
    nix-cachyos-kernel.overlays.pinned
  ];

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
}
