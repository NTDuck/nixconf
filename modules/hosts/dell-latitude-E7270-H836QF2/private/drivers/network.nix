{
  den,
  config,
  ...
}: let
  broadcom_sta = config.boot.kernelPackages.broadcom_sta;
in {
  den.aspects.network-driver = {
    nixos = {
      includes = [
        (den.batteries.unfree [broadcom_sta.name])
        (den.batteries.insecure [broadcom_sta.name])
      ];

      boot.kernelModules = ["wl"];
      boot.blacklistedKernelModules = ["b43" "bcma"];
      boot.extraModulePackages = [broadcom_sta];
    };
  };
}
