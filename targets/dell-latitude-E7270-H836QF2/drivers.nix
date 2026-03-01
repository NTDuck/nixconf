{ config, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    # config.boot.kernelPackages.broadcom_sta.name
    broadcom-sta-6.30.223.271-59-6.19.5
  ];

  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [
    config.boot.kernelPackages.broadcom_sta
  ];
}
