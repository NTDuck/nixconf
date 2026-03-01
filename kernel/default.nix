{ pkgs, nix-cachyos-kernel, ... }:

{
  nixpkgs.overlays = [ nix-cachyos-kernel.overlays.default ];

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
}
