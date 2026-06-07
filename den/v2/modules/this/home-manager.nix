{
  flake.modules.nixos.this-home-manager = {inputs, ...}: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "backup";
    home-manager.extraSpecialArgs = {
      inherit inputs;
    };
  };
}
