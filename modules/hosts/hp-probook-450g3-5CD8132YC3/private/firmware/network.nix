{den, ...}: {
  den.aspects.hp-probook-450g3-5CD8132YC3.nixos = {config, ...}: {
    boot.kernelModules = ["wl"];
    boot.blacklistedKernelModules = ["b43" "bcma"];

    boot.extraModulePackages = [config.boot.kernelPackages.broadcom_sta];
    nixpkgs.config.permittedInsecurePackages = [config.boot.kernelPackages.broadcom_sta.name];
  };
}
