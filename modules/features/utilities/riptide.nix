# Slop
{den, ...}: {
  den.aspects.utilities.riptide = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: let
      version = "1.3.1";

      sources = {
        x86_64-linux = {
          arch = "amd64";
          hash = "sha256-R9ghaxNdtzfuvXROmW6bryCuZcmj6FbqmgOgStMSmog=";
        };

        aarch64-linux = {
          arch = "arm64";
          hash = "sha256-OVWwsTzVg0Z5aEGI8Q274PGVw9Awy4vCvw4aGY1qEj0=";
        };
      };

      system = pkgs.stdenv.hostPlatform.system;

      source =
        sources.${system}
        or throw "Riptide does not provide a release binary for ${system}";

      riptide = pkgs.stdenvNoCC.mkDerivation {
        pname = "riptide";
        inherit version;

        src = pkgs.fetchurl {
          url = "https://github.com/Foxemsx/riptide/releases/download/v${version}/riptide-linux-${source.arch}.tar.gz";
          inherit (source) hash;
        };

        sourceRoot = "riptide-linux-${source.arch}";

        # Upstream's binary uses /lib64/ld-linux-x86-64.so.2, which
        # does not exist directly on NixOS.
        nativeBuildInputs = [
          pkgs.autoPatchelfHook
        ];

        buildInputs = [
          pkgs.glibc
        ];

        dontBuild = true;

        installPhase = ''
          runHook preInstall

          install -Dm755 riptide "$out/bin/riptide"
          install -Dm644 README.md "$out/share/doc/riptide/README.md"
          install -Dm644 LICENSE "$out/share/licenses/riptide/LICENSE"

          runHook postInstall
        '';

        meta = {
          description = "Terminal internet speed test and bandwidth monitor";
          homepage = "https://github.com/Foxemsx/riptide";
          license = lib.licenses.mit;
          mainProgram = "riptide";
          platforms = [
            "x86_64-linux"
            "aarch64-linux"
          ];
        };
      };
    in {
      home.packages = [riptide];
    };
  };
}
