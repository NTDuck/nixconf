{...}: let
  sesori-bridge = {
    pkgs,
    lib,
  }: let
    sources = {
      x86_64-linux = {
        arch = "x64";
        hash = "sha256-y3UkaZ2YpmQkLqcFdRN32OSab1pN688h9yULift9NDU=";
      };
      aarch64-linux = {
        arch = "arm64";
        hash = "sha256-Jdh8AihMIpMlPIZDvfLXL6ZvS00OLXRU+jHibKeJKFs=";
      };
    };
    source =
      sources.${pkgs.stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${pkgs.stdenv.hostPlatform.system}");
  in
    pkgs.stdenv.mkDerivation rec {
      pname = "sesori-bridge";
      version = "1.8.2";

      src = pkgs.fetchurl {
        url = "https://github.com/sesori-ai/sesori_apps_monorepo/releases/download/v${version}/sesori-bridge-linux-${source.arch}.tar.gz";
        inherit (source) hash;
      };

      sourceRoot = ".";

      dontBuild = true;
      dontPatch = true;
      dontStrip = true;
      dontPatchELF = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin $out/lib
        cp bin/sesori-bridge $out/bin/
        cp lib/libsqlite3.so $out/lib/
        runHook postInstall
      '';

      meta = {
        description = "Headless CLI connector for Sesori mobile app";
        homepage = "https://github.com/sesori-ai/sesori_apps_monorepo";
        license = lib.licenses.unfree;
        platforms = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        mainProgram = "sesori-bridge";
      };
    };
in {
  den.aspects.dev.agentics.sesori-bridge = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        (sesori-bridge {
          inherit pkgs;
          inherit (pkgs) lib;
        })
      ];
    };
  };
}
