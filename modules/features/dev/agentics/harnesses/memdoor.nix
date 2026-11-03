{den, ...}: let
  version = "1.786.0";

  # Memdoor (https://github.com/guregodevo/memdoor):
  # A lightweight coding and automation agent in one CLI binary.
  # Packaged from the official upstream static binary release asset.
  memdoor = {
    pkgs,
    lib,
  }:
    pkgs.stdenv.mkDerivation {
      pname = "memdoor";
      inherit version;

      src = pkgs.fetchurl {
        url = "https://github.com/guregodevo/memdoor/releases/download/v${version}/memdoor-linux-amd64";
        hash = "sha256-Elxmi4LeBhdpilL9Scw/if2yjPBPJ68CJWLPpQFUPyA=";
      };

      dontUnpack = true;

      installPhase = ''
        runHook preInstall
        install -Dm755 $src $out/bin/memdoor
        runHook postInstall
      '';

      meta = {
        description = "Coding workflow harness that makes a small model beat a frontier one";
        homepage = "https://github.com/guregodevo/memdoor";
        license = lib.licenses.asl20;
        mainProgram = "memdoor";
        platforms = ["x86_64-linux"];
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      };
    };
in {
  den.aspects.dev.agentics.harnesses.memdoor = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        (memdoor {
          inherit pkgs;
          inherit (pkgs) lib;
        })
      ];
    };
  };
}
