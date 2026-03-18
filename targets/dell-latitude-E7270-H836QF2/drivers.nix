{ config, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages;  # https://github.com/NixOS/nixpkgs/issues/177798#issuecomment-1180609092

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ config.boot.kernelPackages.broadcom_sta.name ];

  boot.kernelModules = [ "wl" ];
  boot.blacklistedKernelModules = [ "b43" "bcma" ];

  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
}
