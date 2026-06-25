{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2.firmware.network = {
    nixos = {config, ...}: {
      boot.kernelModules = ["wl"];
      boot.blacklistedKernelModules = ["b43" "bcma"];

      boot.extraModulePackages = [config.boot.kernelPackages.broadcom_sta];
      nixpkgs.config.permittedInsecurePackages = [config.boot.kernelPackages.broadcom_sta.name];
    };
  };
}
