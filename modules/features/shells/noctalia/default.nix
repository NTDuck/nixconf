{
  den,
  inputs,
  ...
}: {
  den.aspects.shells.noctalia = {
    nixos = {
      nix.settings = {
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
      };
    };

    homeManager = {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      programs.noctalia = {
        enable = true;
        settings = builtins.readFile "${inputs.self}/modules/features/shells/noctalia/noctalia-config.toml";
      };
    };
  };
}
