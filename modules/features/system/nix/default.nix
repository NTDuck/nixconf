{
  den,
  inputs,
  ...
}: {
  den.aspects.system.nix = {
    # nh/nix-ld/nur bundle with the core nixpkgs policy. lix deliberately NOT
    # bundled: it swaps the nix implementation per host (dell keeps CppNix).
    includes = [
      den.aspects.system.nix.nh
      den.aspects.system.nix.nix-ld
      den.aspects.system.nix.nur
    ];

    nixos = {
      pkgs,
      lib,
      ...
    }: let
      config = {
        allowBroken = false;
        # This repository still has several unfree desktop/driver packages.
        # Keep the policy centralized until those exceptions move to aspects.
        allowUnfree = true;

        allowInsecurePredicate = pkg:
          builtins.elem (lib.getName pkg) [
            "pnpm"
            "broadcom-sta"
            # Vesktop 1.6.5 in the pinned unstable set validates against
            # Electron 40 at build time; keep this exception narrow.
            "electron"
            # beekeeper-studio 6.0.5 ships Electron 39 (EOL 2026-03).
            # 2026-09-14: allowInsecurePredicate shadows
            # permittedInsecurePackages (pkgs/stdenv/generic/check-meta.nix),
            # so per-module permit lists are dead — exceptions live here.
            "beekeeper-studio"
          ];
      };
    in {
      nixpkgs = {
        inherit config;

        overlays = [
          (final: prev: {
            unstable = import inputs.nixpkgs-unstable {
              system = pkgs.stdenv.hostPlatform.system;
              inherit config;
            };
          })
        ];
      };
    };
  };
}
