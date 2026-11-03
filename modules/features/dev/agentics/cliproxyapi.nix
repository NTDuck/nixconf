{den, ...}: {
  # CLIProxyAPI (https://github.com/router-for-me/CLIProxyAPI) —
  # reverse proxy server providing OpenAI/Gemini/Claude/Codex-compatible API interfaces
  # wrapping Antigravity, ChatGPT Codex, Claude Code, Grok Build, Kimi, Devin, etc.
  # Packaged from upstream official release binary assets.
  den.aspects.dev.agentics.cliproxyapi = {
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      version = "8.0.52";
      cliProxyApiPkg = pkgs.stdenv.mkDerivation {
        pname = "cli-proxy-api";
        inherit version;

        src = pkgs.fetchurl {
          url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v${version}/CLIProxyAPI_${version}_linux_amd64.tar.gz";
          hash = "sha256-T4hVZHsxB7g+a0otlBj5XYxTxXgnt/CRDPXunISf+Is=";
        };

        nativeBuildInputs = [pkgs.autoPatchelfHook];
        buildInputs = [pkgs.stdenv.cc.cc.lib];

        sourceRoot = ".";

        installPhase = ''
          runHook preInstall
          install -Dm755 cli-proxy-api $out/bin/cli-proxy-api
          ln -s $out/bin/cli-proxy-api $out/bin/cliproxyapi
          ln -s $out/bin/cli-proxy-api $out/bin/cliproxy-api
          ln -s $out/bin/cli-proxy-api $out/bin/CLIProxyAPI
          runHook postInstall
        '';

        meta = {
          description = "Wrap Antigravity, ChatGPT Codex, Claude Code, Grok Build as an OpenAI/Gemini/Claude compatible API service";
          homepage = "https://github.com/router-for-me/CLIProxyAPI";
          license = lib.licenses.mit;
          mainProgram = "cli-proxy-api";
          platforms = ["x86_64-linux"];
        };
      };
    in {
      environment.systemPackages = [
        cliProxyApiPkg
      ];
    };
  };
}
