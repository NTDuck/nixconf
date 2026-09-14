_: let
  # 2026-09-14: lark-cli is not in nixpkgs. The official npm package
  # (@larksuite/cli) is only a Node launcher whose postinstall curls a
  # prebuilt Go binary from GitHub releases — undeclarative. Package the
  # release tarball directly instead; the binary is fully static
  # (`not a dynamic executable`), so no patching is needed.
  larkVersion = "1.0.95";

  # Release asset names use Go arch names (amd64/arm64), not Nix's x86_64/aarch64.
  goArch = {
    x86_64 = "amd64";
    aarch64 = "arm64";
  };

  lark-cli = {
    pkgs,
    lib,
  }:
    pkgs.stdenv.mkDerivation {
      pname = "lark-cli";
      version = larkVersion;

      src = pkgs.fetchurl {
        url =
          # Release asset names embed both GOOS and GOARCH: lark-cli-<v>-linux-amd64.tar.gz.
          "https://github.com/larksuite/cli/releases/download/v${larkVersion}/lark-cli-${larkVersion}-linux-${goArch.${pkgs.stdenv.hostPlatform.parsed.cpu.name}}.tar.gz";
        hash =
          {
            amd64 = "sha256-faktQmt9AAkIx2o2uHp9A1fCcN6/THFJu8YBCyDSVB4=";
            arm64 = "sha256-BjASpjuyJHmFXjNdkizFiLiD4A0RXeUdp2qP/iLbmHo=";
          }.${
            goArch.${pkgs.stdenv.hostPlatform.parsed.cpu.name}
          };
      };

      # Tarball ships flat files (lark-cli, LICENSE, README) — no top-level dir.
      sourceRoot = ".";

      installPhase = ''
        runHook preInstall
        install -Dm755 lark-cli $out/bin/lark-cli
        install -Dm644 LICENSE -t $out/share/licenses/lark-cli
        runHook postInstall
      '';

      meta = {
        description = "Official Lark/Feishu CLI: OpenAPI commands, shortcuts, and AI-agent skills for Messenger, Docs, Base, Calendar, Mail, and Tasks";
        homepage = "https://github.com/larksuite/cli";
        license = lib.licenses.mit;
        mainProgram = "lark-cli";
        platforms = ["x86_64-linux" "aarch64-linux"];
      };
    };
in {
  den.aspects.messenging.lark-cli = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        (lark-cli {
          inherit pkgs;
          inherit (pkgs) lib;
        })
      ];
    };
  };
}
