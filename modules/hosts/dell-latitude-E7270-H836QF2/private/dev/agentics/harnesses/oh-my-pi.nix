# DELL omp client: models.yml points ninfer at LEGION over the tailnet.
#
# Why: DELL has no GPU worth loading 27B on (Intel HD 520); legion serves
# ninfer on 0.0.0.0:8092 with the tailscale0-only firewall open
# (modules/hosts/lenovo-legion-16iah7h-PF3XJ8SP/private/dev/agentics/ninfer.nix,
# 2026-10-10 main-engine switch). MagicDNS resolves the host
# (lenovo-legion-16iah7h-pf3xj8sp.taild3be63.ts.net, verified 2026-09-20),
# but the bare name is enough and keeps working if the tailnet is renamed.
#
# MODELS.YML ON ALL SPECS (2026-10-16 user request): ninfer entry is
# active on the default generation too (previously gated to "remote"
# specialisation), enabling Dell clients to access Qwen 3.8 27B on legion
# over tailnet across all sessions, including ssh.
#
# PROVIDERS (2026-10-16): models.yml carries both the NetMind codev models
# (MiniMax M3, GLM 5.3 Flash) and the legion ninfer provider (Qwen 3.8 / 35B).
# sessionVariables/pi-reasonix extension come from the shared
# dev.agentics.harnesses.oh-my-pi aspect; this file pins models and windows.
#
# 2026-10-19: `ompl` added on Dell host with parity to Legion's ompl,
# pointing to the remote ninfer models on Legion over Tailscale / ssh.
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
      lib,
      ...
    }: let
      yaml = pkgs.formats.yaml {};

      # omp release binary (2026-11-09): upstream omp-linux-x64, hash-
      # pinned in _omp-release.nix, interpreter-only patchelf to the
      # store glibc.
      # Download-only on bumps — no more llm-agents source build.
      ompBinPath =
        import "${inputs.self}/modules/features/dev/agentics/harnesses/omp/_release.nix" {inherit pkgs lib;};

      # Caps Gemini models from default 1M to 256k contextWindow across all active
      # Gemini-bearing providers (2026-10-18 user request).
      geminiOverrides = import "${inputs.self}/modules/features/dev/agentics/harnesses/omp/_gemini-overrides.nix";

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
            id = "qwen3.8-27b-turbo";
            name = "Qwen 3.8 27B Turbo (Heretic)";
            reasoning = true;
            input = ["text" "image"];
            contextWindow = 65536;
            maxTokens = 16384;
          }
        ];
      };

      models = {
        providers =
          lib.recursiveUpdate {
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
          }
          geminiOverrides;
      };

      # `ompl` = a Qwen3.8-27B-ONLY harness mirroring Legion's ompl profile
      # (~/.omp/profiles/ompl/agent): every chat role pinned to the remote
      # ninfer engine on Legion (:8092), running under an isolated profile dir.
      omplOverlay = {
        modelRoles = {
          default = "ninfer/qwen3.8-27b-turbo:high";
          smol = "ninfer/qwen3.8-27b-turbo:high";
          slow = "ninfer/qwen3.8-27b-turbo:high";
          vision = "ninfer/qwen3.8-27b-turbo:high";
          plan = "ninfer/qwen3.8-27b-turbo:high";
          commit = "ninfer/qwen3.8-27b-turbo:high";
          task = "ninfer/qwen3.8-27b-turbo:high";
          advisor = "ninfer/qwen3.8-27b-turbo:high";
          judge = "ninfer/qwen3.8-27b-turbo:high";
        };

        enabledModels = [
          "ninfer/qwen3.8-27b"
          "ninfer/qwen3.8-27b-turbo"
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
      # remote ninfer endpoint over Tailscale.
      omplModels = {
        providers = {
          ninfer = ninferProvider;
        };
      };

      # `omprp` = roleplaying harness on Dell (2026-11-01): runs under `--profile omprp`
      # (~/.omp/profiles/omprp/agent) wired to Legion's remote ninfer engine over Tailscale.
      # Tuned for roleplay and creative prose:
      #   hideThinkingBlock: true      - suppress reasoning/thinking logs in output
      #   memory.backend: mnemopi      - persistent SQLite memory across sessions
      #   autolearn.enabled: true      - persist learnings and memories
      #   vibe.defaultOnStartup: false - vibe mode disabled
      #   advisor.enabled: false       - advisor runtime disabled (no passive turns/notes)
      #   personality: "none"          - omit engineering personality constraints
      #   git.enabled: false           - suppress git branch/status checks and UI indicators
      omprpOverlay = {
        modelRoles = {
          default = "ninfer/qwen3.8-27b-turbo:high";
          smol = "ninfer/qwen3.8-27b-turbo:high";
          slow = "ninfer/qwen3.8-27b-turbo:high";
          vision = "ninfer/qwen3.8-27b-turbo:high";
          plan = "ninfer/qwen3.8-27b-turbo:high";
          commit = "ninfer/qwen3.8-27b-turbo:high";
          task = "ninfer/qwen3.8-27b-turbo:high";
          advisor = "ninfer/qwen3.8-27b-turbo:high";
          judge = "ninfer/qwen3.8-27b-turbo:high";
        };

        enabledModels = [
          "ninfer/qwen3.8-27b"
          "ninfer/qwen3.8-27b-turbo"
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

        hideThinkingBlock = true;
        memory.backend = "mnemopi";
        autolearn.enabled = true;

        vibe.defaultOnStartup = false;
        advisor.enabled = false;
        personality = "none";
        git.enabled = false;
      };

      omprpModels = omplModels;

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
      home.file.".omp/agent/omprp.yml" = {
        source = yaml.generate ".omp.agent.omprp.yml" omprpOverlay;
        force = true;
      };

      # --- omprp profile support files (~/.omp/profiles/omprp/agent/) ---
      home.file.".omp/profiles/omprp/agent/models.yml" = {
        source = yaml.generate ".omp.agent.omprp-models.yml" omprpModels;
        force = true;
      };
      home.file.".omp/profiles/omprp/agent/keybindings.yml" = {
        text = ''
          keybindings:
            app.clipboard.pasteImage: "alt+v"
        '';
        force = true;
      };

      home.file.".omp/profiles/omprp/agent/extensions/pi-reasonix.js" = {
        source = "${reasonixPkg}/share/omp/extensions/pi-reasonix.js";
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
          ${ompBinPath}/bin/omp
        '');

        ompl = lib.removeSuffix "\n" ''
          active_model="$( ${pkgs.curl}/bin/curl -s -m 0.5 http://lenovo-legion-16iah7h-pf3xj8sp:8092/v1/models 2>/dev/null | ${pkgs.jq}/bin/jq -r '.data[0].id // empty' 2>/dev/null || true )"
          active_model="''${active_model:-qwen3.8-27b-turbo}"
          runtime_dir="''${XDG_RUNTIME_DIR:-/tmp}/omp"
          mkdir -p "$runtime_dir"
          active_overlay="$runtime_dir/ompl-active.yml"
          cat << EOF > "$active_overlay"
          modelRoles:
            default: ninfer/$active_model:high
            smol: ninfer/$active_model:high
            slow: ninfer/$active_model:high
            vision: ninfer/$active_model:high
            plan: ninfer/$active_model:high
            commit: ninfer/$active_model:high
            task: ninfer/$active_model:high
            advisor: ninfer/$active_model:high
            judge: ninfer/$active_model:high
          EOF
          PI_CONFIG_FILES="$HOME/.omp/agent/config.default.yml:$HOME/.omp/agent/ompl.yml:$active_overlay" \
          ${ompBinPath}/bin/omp --profile ompl
        '';

        omprp = lib.removeSuffix "\n" ''
          active_model="$( ${pkgs.curl}/bin/curl -s -m 0.5 http://lenovo-legion-16iah7h-pf3xj8sp:8092/v1/models 2>/dev/null | ${pkgs.jq}/bin/jq -r '.data[0].id // empty' 2>/dev/null || true )"
          active_model="''${active_model:-qwen3.8-27b-turbo}"
          runtime_dir="''${XDG_RUNTIME_DIR:-/tmp}/omp"
          mkdir -p "$runtime_dir"
          active_overlay="$runtime_dir/omprp-active.yml"
          cat << EOF > "$active_overlay"
          modelRoles:
            default: ninfer/$active_model:high
            smol: ninfer/$active_model:high
            slow: ninfer/$active_model:high
            vision: ninfer/$active_model:high
            plan: ninfer/$active_model:high
            commit: ninfer/$active_model:high
            task: ninfer/$active_model:high
            advisor: ninfer/$active_model:high
            judge: ninfer/$active_model:high
          EOF
          PI_CONFIG_FILES="$HOME/.omp/agent/config.default.yml:$HOME/.omp/agent/omprp.yml:$active_overlay" \
          ${ompBinPath}/bin/omp --profile omprp
        '';
      };
    };
  };
}
