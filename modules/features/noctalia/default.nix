{
  den,
  inputs,
  ...
}: let
  noctaliaPackage = pkgs:
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      # The upstream package's test targets currently fail late in the Nix
      # Meson build on this pin; Noctalia itself builds and runs without them.
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
      # Keep the TOML readable as `${inputs.self}/...` while still handing
      # Noctalia concrete store paths at evaluation time.
      settings =
        builtins.replaceStrings
        ["\${inputs.self}"]
        ["${inputs.self}"]
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
