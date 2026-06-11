{ den, inputs, ... }: {
  den.aspects."home-manager" = {
    nixos = { ... }: {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = { inherit inputs; };
    };
  };
}
