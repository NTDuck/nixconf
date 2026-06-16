{
  den,
  inputs,
  ...
}: {
  den.aspects.lenovo-legion = {
    nixos = {pkgs, ...}: {
      imports = [
        inputs.nixos-hardware.nixosModules.lenovo-legion-16iah7h
      ];

      environment.systemPackages = [
        pkgs.lenovo-legion
      ];
    };
  };
}
