{
  lib,
  pkgs,
}: let
  version = "1.1.0";
in
  # pi-reasonix (restored 2026-10-20, exact shape of the pre-9011d32
  # block): DeepSeek-native optimizations — cache-first prefix
  # stabilization, tool-call repair, cost control. Activates only for
  # model ids containing "deepseek-"; zero overhead elsewhere.
  pkgs.stdenv.mkDerivation {
    pname = "pi-reasonix";
    inherit version;

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
  }
