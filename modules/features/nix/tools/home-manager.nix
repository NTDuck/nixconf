{den, inputs, ...}: {
  den.aspects.home-manager-integration = {
    nixos = { lib, ... }: {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    };
    homeManager = { lib, ... }: {
      home.stateVersion = lib.mkDefault "26.05";
      programs.home-manager.enable = true;
    };
  };
}
