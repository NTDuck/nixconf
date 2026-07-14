{
  den,
  inputs,
  ...
}: {
  den.aspects.noctalia = {
    nixos = {
      nix.settings = {
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
      };
    };

    homeManager = let
      assetRoot = "${inputs.self}/assets";
      settings =
        builtins.replaceStrings
        ["@assetRoot@"]
        [assetRoot]
        (builtins.readFile "${inputs.self}/modules/features/noctalia/noctalia-config.toml");
    in {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      programs.noctalia = {
        enable = true;
        inherit settings;
      };
    };
  };
}
