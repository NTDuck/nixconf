{
  den,
  inputs,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.provides.to-users = {user, ...}: {
    nixos = {
      imports = [
        inputs.nixos-hardware.nixosModules.lenovo-legion-16iah7h
      ];
    };
  };
}
