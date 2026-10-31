# DELL omp client: models.yml points ashalliant at LEGION over the tailnet.
#
# Why: DELL has no GPU worth loading 27B on (Intel HD 520); legion serves
# ashalliants on 0.0.0.0:8092 with the tailscale0-only firewall open
# (modules/hosts/lenovo-legion-16iah7h-PF3XJ8SP/private/dev/agentics/ashalliants.nix,
# 2026-10-10 main-engine switch). MagicDNS resolves the host
# (lenovo-legion-16iah7h-pf3xj8sp.taild3be63.ts.net, verified 2026-09-20),
# but the bare name is enough and keeps working if the tailnet is renamed.
#
# MODELS.YML ON ALL SPECS (2026-10-16 user request): ashalliants entry is
# active on the default generation too (previously gated to "remote"
# specialisation), enabling Dell clients to access Qwen 3.8 27B on legion
# over tailnet across all sessions, including ssh.
#
# PROVIDERS (2026-10-16): models.yml carries both the NetMind codev models
# (MiniMax M3, GLM 5.3 Flash) and the legion ashalliant provider (Qwen 3.8 / 35B).
# sessionVariables/pi-reasonix extension come from the shared
# dev.agentics.harnesses.oh-my-pi aspect; this file pins models and windows.
#
# 2026-10-19: `ompl` added on Dell host with parity to Legion's ompl,
# pointing to the remote ashalliant models on Legion over Tailscale / ssh.
{
  den,
  inputs,
  lib,
  ...
}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    homeManager = {
      osConfig,
      pkgs,
      ...
    }: let
      yaml = pkgs.formats.yaml {};

      # Caps Gemini models from default 1M to 256k contextWindow across all active
      # Gemini-bearing providers (2026-10-18 user request).
      geminiOverrides = import "${inputs.self}/modules/features/dev/agentics/harnesses/_omp-gemini-overrides.nix";

      # Consolidated ninfer engine on legion (port 8092 over tailscale0).
      # Single provider hosting all 4 canonical model variants (27B DFlash2, 27B Abliterated,
      # 35B MTP3, 35B Abliterated). Legion's daemon on :8092 serves whichever model is active.
      ninferProvider = {
        baseUrl = "http://lenovo-legion-16iah7h-pf3xj8sp:8092/v1";
        api = "openai-completions";
        auth = "none";

        models = [
          {
            id = "qwen3.8-27b";
            name = "Qwen 3.8 27B";
            reasoning = true;
            input = ["text" "image"];
            contextWindow = 65536;
            maxTokens = 16384;
          }
          {
            id = "qwen3.8-27b-abliterated";
            name = "Qwen 3.8 27B (Abliterated)";
            reasoning = true;
            input = ["text" "image"];
            contextWindow = 65536;
            maxTokens = 16384;
          }
          {
            id = "qwen3.6-35b-a3b";
            name = "Qwen 3.6 35B A3B (Vision)";
            reasoning = true;
            input = ["text" "image"];
            contextWindow = 65536;
            maxTokens = 16384;
          }
          {
            id = "qwen3.6-35b-a3b-abliterated";
            name = "Qwen 3.6 35B A3B (Abliterated)";
            reasoning = true;
            input = ["text" "image"];
            contextWindow = 65536;
            maxTokens = 16384;
          }
          {
            id = "hemmingway-1-abliterated";
            name = "Hemmingway-1 (Abliterated)";
            reasoning = true;
            input = ["text" "image"];
            contextWindow = 262144;
            maxTokens = 16384;
          }
          # 2026-10-31: Non-thinking variant of Hemmingway-1 Abliterated for low-latency turns
          {
            id = "hemmingway-1-abliterated-nth";
            name = "Hemmingway-1 (Abliterated, non-thinking)";
            reasoning = false;
            input = ["text" "image"];
            contextWindow = 262144;
            maxTokens = 16384;
          }
        ];
      };

      models = {
        providers = lib.recursiveUpdate {
          # NetMind CodeV gateway (restored 2026-10-16 per user request).
          codev = {
            baseUrl = "https://netmind.viettel.vn/gateway/v1";
            api = "openai-completions";
            apiKey = "CODEV_API_KEY";
            authHeader = true;

            models = [
              {
                id = "MiniMax/MiniMax-M3";
                name = "MiniMax M3 (NetMind)";
                contextWindow = 196608;
                maxTokens = 65536;
              }
              {
                id = "zai-org/GLM-5.3-Flash";
                name = "GLM 5.3 Flash (NetMind)";
                contextWindow = 1048576;
                maxTokens = 131072;
              }
            ];
          };

          ninfer = ninferProvider;
          # Backward-compat alias (2026-10-31): retain ashalliant provider mapping to ninfer
          ashalliant = ninferProvider;
        } geminiOverrides;
      };

      # `ompl` = a Qwen3.8-27B-ONLY harness mirroring Legion's ompl profile
      # (~/.omp/profiles/ompl/agent): every chat role pinned to the remote
      # ashalliant engine on Legion (:8092), running under an isolated profile dir.
      omplOverlay = {
        modelRoles = {
          default = "ninfer/qwen3.8-27b-abliterated:high";
          smol = "ninfer/qwen3.8-27b-abliterated:high";
          slow = "ninfer/qwen3.8-27b-abliterated:high";
          vision = "ninfer/qwen3.8-27b-abliterated:high";
          plan = "ninfer/qwen3.8-27b-abliterated:high";
          commit = "ninfer/qwen3.8-27b-abliterated:high";
          task = "ninfer/qwen3.8-27b-abliterated:high";
          advisor = "ninfer/qwen3.8-27b-abliterated:high";
          judge = "ninfer/qwen3.8-27b-abliterated:high";
        };

        enabledModels = [
          "ninfer/qwen3.8-27b"
          "ninfer/qwen3.8-27b-abliterated"
          "ninfer/qwen3.6-35b-a3b"
          "ninfer/qwen3.6-35b-a3b-abliterated"
          "ninfer/hemmingway-1-abliterated"
          "ninfer/hemmingway-1-abliterated-nth"
        ];
        disabledProviders = [
          # implicit keyless local probes
          "llama.cpp"
          "lm-studio"
          "apple"
          # env-var/stored-credential cloud ids observed on this host
          "codev"
          "litellm"
          "openrouter"
          "opencode-go"
          "opencode-zen"
          "google-antigravity"
          "openai-codex"
        ];

        retry.modelFallback = false;

        memory.backend = "off";
        autolearn.enabled = false;
      };

      # Profile-local qwen-only models.yml for Dell: points to Legion's
      # remote ashalliant endpoint over Tailscale.
      omplModels = {
        providers = {
          ninfer = ninferProvider;
          # Backward-compat alias (2026-10-31): retain ashalliant provider mapping to ninfer
          ashalliant = ninferProvider;
        };
      };

      # Reasonix extension package (cache-first prefix stabilization)
      # isolated inside the ompl profile.
      reasonixPkg = pkgs.stdenv.mkDerivation rec {
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
          license = pkgs.lib.licenses.mit;
        };
      };
    in {
      # force = true (2026-10-16): self-heal over any pre-existing unmanaged
      # models.yml on disk (e.g. manual symlinks) so HM activation does not fail.
      home.file.".omp/agent/models.yml" = {
        source = yaml.generate ".omp.agent.models.yml" models;
        force = true;
      };

      # PI_CONFIG_FILES overlay (merged OVER config.yml/config.default.yml; later overlays win).
      home.file.".omp/agent/ompl.yml" = {
        source = yaml.generate ".omp.agent.ompl.yml" omplOverlay;
        force = true;
      };

      # --- ompl profile support files (~/.omp/profiles/ompl/agent/) ---
      home.file.".omp/profiles/ompl/agent/models.yml" = {
        source = yaml.generate ".omp.agent.ompl-models.yml" omplModels;
        force = true;
      };
      home.file.".omp/profiles/ompl/agent/keybindings.yml" = {
        text = ''
          keybindings:
            app.clipboard.pasteImage: "alt+v"
        '';
        force = true;
      };

      home.file.".omp/profiles/ompl/agent/extensions/pi-reasonix.js" = {
        source = "${reasonixPkg}/share/omp/extensions/pi-reasonix.js";
        force = true;
      };

      # omp wrapper alias (2026-10-16): inject CODEV_API_KEY from agenix decrypted secret
      home.shellAliases = {
        omp = lib.mkForce (lib.removeSuffix "\n" ''
          CODEV_API_KEY="$(cat ${osConfig.age.secrets."codev-api-key".path} 2>/dev/null || cat ~/.codev/auth.json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.api_key // empty')" \
          PI_CONFIG_FILES="$HOME/.omp/agent/config.default.yml" \
          ${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp}/bin/omp
        '');

        ompl = lib.removeSuffix "\n" ''
          PI_CONFIG_FILES="$HOME/.omp/agent/config.default.yml:$HOME/.omp/agent/ompl.yml" \
          ${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp}/bin/omp --profile ompl
        '';
      };
    };
  };
}
