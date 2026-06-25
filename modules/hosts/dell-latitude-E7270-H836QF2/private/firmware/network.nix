{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2.firmware.network = {
    nixos = {config, ...}: {
      nixpkgs.config.allowUnfreePredicate = pkg: pkg.pname == "broadcom-sta";

      boot.kernelModules = ["wl"];
      boot.blacklistedKernelModules = ["b43" "bcma"];
      boot.extraModulePackages = [config.boot.kernelPackages.broadcom_sta];
    };
  };
}
