{
  den,
  inputs,
  ...
}: let
  noctaliaPackage = pkgs:
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      mesonFlags =
        (old.mesonFlags or [])
        ++ [
          "-Dtests=disabled"
        ];
    });
in {
  den.aspects.noctalia = {
    nixos = {
      nix.settings = {
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
      };
    };

    homeManager = {pkgs, ...}: let
      settings =
        builtins.replaceStrings
        ["@assetRoot@"]
        ["${inputs.self}/assets"]
        (builtins.readFile "${inputs.self}/modules/features/noctalia/noctalia-config.toml");
    in {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      programs.noctalia = {
        enable = true;
        package = noctaliaPackage pkgs;
        inherit settings;
      };
    };
  };
}
