{
  den,
  inputs,
  ...
}: {
  den.aspects.home-manager-integration = {
    nixos = {
      lib,
      ...
    }: {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    };
  };
}
