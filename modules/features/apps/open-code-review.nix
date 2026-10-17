let
  # 2026-10-17: open-code-review (ocr) is not in nixpkgs. The upstream
  # install.sh curls a prebuilt Go binary from GitHub releases — package the
  # release asset directly instead. Binary is fully static Go, no patching.
  ocrVersion = "1.13.1";

  # Release asset names use Go arch names (amd64/arm64), not Nix's x86_64/aarch64.
  goArch = {
    x86_64 = "amd64";
    aarch64 = "arm64";
  };
in
  {
    den,
    lib,
    ...
  }: {
    den.aspects.apps.open-code-review = {
      nixos = {
        pkgs,
        lib,
        ...
      }: {
        environment.systemPackages = [
          (pkgs.stdenv.mkDerivation {
            pname = "open-code-review";
            version = ocrVersion;

            src = pkgs.fetchurl {
              url = "https://github.com/alibaba/open-code-review/releases/download/v${ocrVersion}/opencodereview-linux-${goArch.${pkgs.stdenv.hostPlatform.parsed.cpu.name}}";
              hash = {
                amd64 = "sha256-OoJIuVkXeBT8OKGmu4d0KYUQPoOb/kWC2XrjDZad2RM=";
                arm64 = "sha256-moR//Yr8G0J9x1l8WATqidIXMlDX/0vcWP1VzDFd81s=";
              }.${
                goArch.${pkgs.stdenv.hostPlatform.parsed.cpu.name}
              };
            };

            dontUnpack = true;

            installPhase = ''
              runHook preInstall
              install -Dm755 $src $out/bin/ocr
              runHook postInstall
            '';

            meta = {
              description = "AI-powered code review CLI: reads Git diffs, generates structured line-level comments with a built-in fine-tuned ruleset";
              homepage = "https://github.com/alibaba/open-code-review";
              license = lib.licenses.asl20;
              mainProgram = "ocr";
              platforms = ["x86_64-linux" "aarch64-linux"];
            };
          })
        ];
      };
    };
  }
