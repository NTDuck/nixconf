{ config, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ config.boot.kernelPackages.broadcom_sta.name ];

  boot.kernelModules = [ "wl" ];
  boot.blacklistedKernelModules = [ "b43" "bcma" ];

  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
}
