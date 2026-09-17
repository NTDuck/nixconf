{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    nixos = {config, ...}: {
      boot.kernelModules = ["wl"];
      boot.blacklistedKernelModules = ["b43" "bcma" "brcmfmac"];

      boot.extraModulePackages = [config.boot.kernelPackages.broadcom_sta];
      # permittedInsecurePackages NOT set here: central allowInsecurePredicate
      # in modules/features/system/nix/default.nix already covers broadcom-sta.
    };
  };
}
