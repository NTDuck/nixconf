{den, inputs, ...}: {
  den.aspects.noctalia-shell = {
    nixos = {...}: {
      imports = [inputs.noctalia.nixosModules.default];
      # Wait, Noctalia's docs say we can just use `programs.noctalia-shell` in home-manager. 
      # Sometimes the nixos module exposes `programs.noctalia-shell.enable`. Let's enable it there or via HM.
    };
    homeManager = {...}: {
      imports = [inputs.noctalia.homeManagerModules.default];
      programs.noctalia-shell = {
        enable = true;
      };
    };
  };
}
