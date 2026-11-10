{den, ...}: {
  # CLIProxyAPI (https://github.com/router-for-me/CLIProxyAPI) —
  # reverse proxy server providing OpenAI/Gemini/Claude/Codex-compatible API interfaces
  # wrapping Antigravity, ChatGPT Codex, Claude Code, Grok Build, Kimi, Devin, etc.
  # Packaged from upstream official release binary assets.
  den.aspects.dev.agentics.cliproxyapi = {
    nixos = {
      pkgs,
      lib,
      config,
      ...
    }: let
      version = "8.0.52";

      cli-proxy-api = pkgs.stdenv.mkDerivation {
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

      # Loopback-only listener; agents (omp, curl callers) reach it on
      # 127.0.0.1:8317. Upstream default port is 8317.
      port = 8317;
      stateDir = "/var/lib/cli-proxy-api";
    in {
      environment.systemPackages = [
        cli-proxy-api
        # Terminal invocation (pattern from the gemini-web2api aspect):
        # opens the management control panel, then streams the unit
        # journal. Management key = the client api-key (first boot
        # generates it; `cat` below needs the service to have run once).
        (pkgs.writeShellScriptBin "cliproxyapi" ''
          port=${toString port}
          key="$(cat ${stateDir}/api-key 2>/dev/null || true)"
          url="http://127.0.0.1:$port/management/"
          if [ -n "$key" ] && command -v xdg-open >/dev/null 2>&1; then
            # Panel asks for the management key; print it for pasting.
            echo "cliproxyapi: management key: $key"
            ${pkgs.xdg-utils}/bin/xdg-open "$url" >/dev/null 2>&1 || true
          fi
          echo "cliproxyapi: streaming cli-proxy-api logs — Ctrl+C to stop"
          exec ${pkgs.systemd}/bin/journalctl --no-pager -n 5 -fu cli-proxy-api
        '')
      ];

      systemd.services.cli-proxy-api = {
        description = "CLIProxyAPI (OpenAI/Gemini/Claude-compatible gateway for CLI-agent OAuth credentials)";
        wantedBy = ["multi-user.target"];
        wants = ["network-online.target"];
        after = ["network-online.target"];

        preStart = let
          # v8 config layout (config.example.yaml, v8.0.52). Client
          # api-keys double as the management key so the control panel
          # works without a second secret. Management restricted to
          # localhost (allow-remote: false default). Discovery off.
          configFile = pkgs.writers.writeYAML "cli-proxy-api-config.yaml" {
            config-version = 8;
            server = {
              host = "127.0.0.1";
              inherit port;
            };
            access.api-keys = ["\${API_KEY}"];
            oauth.auth-dir = "${stateDir}/auths";
          };
        in ''
          # First boot: generate a random client/management API key.
          # Loopback-only exposure; the key file is root-owned 0640 with
          # group=users so omp's alias (running as ayin, wheel) can read
          # it without sudo (wheel has implicit root via sudo, but the
          # direct read avoids a sudo prompt on every omp launch).
          if [ ! -s ${stateDir}/api-key ]; then
            ${pkgs.pwgen}/bin/pwgen -s 32 1 > ${stateDir}/api-key
          fi
          chown root:users ${stateDir}/api-key
          chmod 640 ${stateDir}/api-key
          install -m 600 ${configFile} ${stateDir}/config.yaml
          # Substitute the generated key into the config (envsubst-style
          # since writeYAML cannot interpolate runtime secrets).
          ${pkgs.gnused}/bin/sed -i "s/\''${API_KEY}/$(cat ${stateDir}/api-key)/" ${stateDir}/config.yaml
          mkdir -p ${stateDir}/auths
        '';

        script = ''
          exec ${cli-proxy-api}/bin/cli-proxy-api --config ${stateDir}/config.yaml
        '';

        serviceConfig = {
          Type = "simple";
          StateDirectory = "cli-proxy-api";
          WorkingDirectory = stateDir;
          Restart = "on-failure";
          RestartSec = 5;
          # The OAuth login flows write credential JSONs into auth-dir;
          # the service needs network for token refresh.
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ReadWritePaths = [stateDir];
        };
      };
    };
  };
}
