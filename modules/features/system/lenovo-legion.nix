{
  den,
  inputs,
  ...
}: {
  den.aspects.lenovo-legion = {
    nixos = {
      pkgs,
      config,
      ...
    }: {
      imports = [
        inputs.nixos-hardware.nixosModules.lenovo-legion-16iah7h
      ];

      environment.systemPackages = [
        pkgs.unstable.lenovo-legion
      ];

      boot.extraModulePackages = [
        config.boot.kernelPackages.lenovo-legion-module
      ];

      boot.kernelModules = [
        "lenovo-legion-module"
      ];
    };
  };
}
