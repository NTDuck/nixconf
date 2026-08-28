{
  den,
  inputs,
  ...
}: let
  pi-reasonix = {
    pkgs,
    lib,
  }:
    pkgs.stdenv.mkDerivation rec {
      pname = "pi-reasonix";
      version = "1.1.0";

      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/pi-reasonix/-/pi-reasonix-${version}.tgz";
        hash = "sha512-pK9ig80y8l8shFoWGJx+ylg+dQ2qj9a/3z+nIkCDcsCW+3TsbqyeNrm0B/Pb4YcaczUjDBnVJHtByzbh+JJVzQ==";
      };

      dontBuild = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/node_modules/pi-reasonix
        cp -r * $out/lib/node_modules/pi-reasonix/
        mkdir -p $out/share/omp/extensions
        ln -s $out/lib/node_modules/pi-reasonix/dist/extensions/index.js $out/share/omp/extensions/pi-reasonix.js
        runHook postInstall
      '';

      meta = {
        description = "DeepSeek-native optimizations for Pi / Oh-My-Pi: cache-first prefix stabilization, tool-call repair, and cost control";
        homepage = "https://github.com/TheTrebor/pi-reasonix";
        license = lib.licenses.mit;
      };
    };
in {
  den.aspects.dev.agentics.harnesses.oh-my-pi = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp
        (pi-reasonix {
          inherit pkgs;
          inherit (pkgs) lib;
        })
      ];
    };

    homeManager = {pkgs, ...}: let
      reasonixPkg = pi-reasonix {
        inherit pkgs;
        inherit (pkgs) lib;
      };
    in {
      home.file.".omp/agent/extensions/pi-reasonix.js".source = "${reasonixPkg}/share/omp/extensions/pi-reasonix.js";

      home.sessionVariables = {
        REASONIX_SCAVENGE = "1";
        REASONIX_RESULT_CAP_TOKENS = "3000";
      };
    };
  };
}
