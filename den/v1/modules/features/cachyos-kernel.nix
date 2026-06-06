{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.nixos.cachyos-kernel = {

  nixpkgs.overlays = [inputs.cachyos-kernel.overlays.pinned];
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  };
}
