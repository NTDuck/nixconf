# Legion omp client: models.yml + the `omp` alias (host-private).
#
# SHAPE HISTORY (2026-09-27): 4e3be54 (2026-09-26 18:37, user-directed
# revert) restored this file verbatim to a pre-fb75273 LITERAL models.yml
# — which dropped the homelab ollama/bonsai2 local provider blocks that
# fb75273 (same day, 12:52) had added and live-verified ("omp -p
# --model=ollama/qwen3.8:27b -> pong"). models.yml REPLACES omp's implicit
# catalog, so without an ollama provider entry /model lists NO local
# ollama models at all — qwen3.8:27b "not available on ohmypi" on the
# homelab spec. Fix: local blocks restored as a spec-gated attrset (the
# literal .text shape cannot express the specialisation gate); the
# 4e3be54 alias (5-secret export) and cloud providers are kept verbatim.
{inputs, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    homeManager = {
      osConfig,
      pkgs,
      ...
    }: let
      yaml = pkgs.formats.yaml {};

      # 3090 gating (2026-09-21, 3090 specialisation pattern): the local
      # ollama provider (:11434) exists ONLY inside the homelab
      # specialisation — the daemon it points at is gated there too
      # (ollama.nix). osConfig.isSpecialisation is mkOverride-0 true
      # inside spec evals (nixos/modules/system/activation/no-clone.nix)
      # and false in the default generation, so the two models.yml
      # variants diverge on this flag and there is no module collision
      # (the spec HM eval replaces the default HM config wholesale).
      onHomelabSpec = osConfig.isSpecialisation or false;

      cloudProviders = {
        # https://docs.orcarouter.ai/integrations/oh-my-pi
        # (2026-09-27 note: orcarouter-api-key.age still decrypts to 0
        # bytes — key lost 2026-09-26. Kept per the 4e3be54 user-directed
        # revert; calls 401 until a fresh key is fed via `agenix -e`.)
        orcarouter = {
          baseUrl = "https://api.orcarouter.ai/v1";
          api = "openai-completions";
          apiKey = "ORCAROUTER_API_KEY";
          authHeader = true;

          models = [
            {
              id = "orcarouter/auto";
              name = "OrcaRouter";
              reasoning = false;
              input = ["text"];
              contextWindow = 200000;
              maxTokens = 8192;

              compat = {
                supportsDeveloperRole = false;
                maxTokensField = "max_tokens";
              };
            }
          ];
        };

        # https://tabitoken.com/pricing
        tabitoken = {
          baseUrl = "https://tabitoken.com/v1";
          api = "openai-completions";
          apiKey = "TABIAI_API_KEY";

          models = [
            {
              id = "claude-opus-5";
              name = "Claude Opus 5";
              contextWindow = 200000;
              maxTokens = 8192;
            }

            {
              id = "claude-opus-5-thinking";
              name = "Claude Opus 5 (Thinking)";
              contextWindow = 200000;
              maxTokens = 8192;
            }

            {
              id = "claude-opus-4-8";
              name = "Claude Opus 4.8";
              contextWindow = 200000;
              maxTokens = 8192;
            }

            {
              id = "claude-opus-4-8-thinking";
              name = "Claude Opus 4.8 (Thinking)";
              contextWindow = 200000;
              maxTokens = 8192;
            }
          ];
        };

        # https://netmind.viettel.vn/codev/vi/docs/hub/installation#install-sso
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

            # Gateway-reported id (curl /v1/models 2026-09-26); the gateway
            # omits max_input_tokens/max_output_tokens for this entry, so
            # pin to the same conservative window as MiniMax/MiniMax-M3
            # (gateway reports 1M/128K for that one but trims in practice).
            {
              id = "zai-org/GLM-5.3-Flash";
              name = "GLM 5.3 Flash (NetMind)";
              reasoning = true;
              contextWindow = 196608;
              maxTokens = 65536;
            }
          ];
        };
      };

      # 3090-coupled local providers — homelab spec only (see
      # onHomelabSpec). Restored verbatim from fb75273 (2026-09-26), the
      # last live-verified state.
      local = {
        ollama = {
          # /v1 REQUIRED (2026-09-21): omp's openai-responses adapter posts
          # <baseUrl>/responses verbatim — no /v1 of its own (journal showed
          # 404 POST "/responses"; ollama serves OpenAI-compat under /v1).
          # Same convention as the codev cloud provider above.
          baseUrl = "http://127.0.0.1:11434/v1";
          api = "openai-responses";
          auth = "none";
          discovery.type = "ollama";
          # qwen3.8:27b (official max, 2026-09-27): /api/show reports the
          # raw model card qwen35.context_length = 262144 — same
          # overclaim as the Hemmingway entry below -> trim ->
          # "no user query found in messages" 500-loop (ollama #17778)
          # once the 131072 real window is exceeded. Pin to the daemon's
          # real window (OLLAMA_CONTEXT_LENGTH). Tag case MUST match
          # /api/tags verbatim: `qwen3.8:27b`.
          modelOverrides."qwen3.8:27b" = {
            contextWindow = 131072;
            maxTokens = 16384;
          };
          modelOverrides."qwen3.8:27b-mtp-q4_K_M" = {
            # 128k to match OLLAMA_CONTEXT_LENGTH (q4_0 KV makes 131072
            # fit the 3090; see ollama.nix).
            contextWindow = 131072;
            maxTokens = 16384;
          };
          # Hemmingway-1 Q4_K_M (added 2026-09-21): ollama's bundled
          # catalog claims contextWindow 262144 for this qwen35-arch
          # quant too — same overclaim -> trim -> "no user query found
          # in messages" 500-loop as qwen3.8:27b (ollama #17778). Pin
          # to the daemon's real window (OLLAMA_CONTEXT_LENGTH).
          # Tag case MUST match /api/tags verbatim (2026-09-26): the
          # daemon lists `:q4_K_M` (lowercase q) — the old `:Q4_K_M`
          # key matched nothing, so the override was silently inert
          # (omp models showed the discovered 128K, not this pin).
          modelOverrides."hf.co/bartowski/Altworld_Hemmingway-1-GGUF:q4_K_M" = {
            contextWindow = 131072;
            maxTokens = 16384;
          };
        };

        # ashalliants ninfer-0.15.0 DFlash2 (:8092 — see
        # ../ashalliants.nix; 2026-10-09 benchmark WINNER for Qwen3.8 on
        # both criteria: peak 162.7 tok/s fresh C1 AND high-parallelism x
        # deep-ctx). Same OpenAI Chat Completions shape (the
        # vendor binary serves completions/responses/anthropic; no
        # /v1/models discovery — declared model instead). id matches the
        # server banner ("listening ... | model qwen3.8-27b"). 262144 =
        # tuned-profile context (NINFER_FALLBACK=off keeps it exact;
        # overclaim triggers omp's trim 500-loop — never overclaim).
        # On-demand unit (23.3 GiB VRAM + 2 GiB pinned host KV): start
        # via `ashalliants-up` (Conflicts stop ninfer-serve/bonsai2/
        # ollama natively); provider 404s until the unit is up.
        ashalliants = {
          baseUrl = "http://127.0.0.1:8092/v1";
          api = "openai-completions";
          auth = "none";

          models = [
            {
              id = "qwen3.8-27b";
              name = "Qwen 3.8 27B";
              reasoning = true;
              input = ["text"];
              contextWindow = 262144;
              maxTokens = 16384;
            }
          ];
        };
      };

      models = {
        providers =
          cloudProviders
          // (
            if onHomelabSpec
            then local
            else {}
          );
      };

      # `ompl` = a Qwen3.8-27B-ONLY harness: every chat role pinned to
      # the local ashalliants engine (:8092, ../ashalliants.nix), running
      # under a dedicated `--profile ompl` agent dir
      # (~/.omp/profiles/ompl/agent). The profile isolates ALL agent
      # state — sessions, history.db, agent.db, models.db, stored auth,
      # memories, blobs, terminal-sessions — from the default
      # ~/.omp/agent dir ("no memory or persistence" user requirement,
      # 2026-10-11): nothing ompl does lands in omp's shared store, and
      # the fresh profile starts with NO stored cloud credentials.
      #
      # models.yml resolves from the ACTIVE agent dir, so the profile
      # needs its own qwen-only models.yml (omplModels below) — the
      # shared ~/.omp/agent/models.yml (cloud + ollama) is NOT visible
      # to it. Without a profile-local file the ashalliants selector is
      # unresolvable and the harness SILENTLY degrades to a cloud model:
      # reproduced 2026-10-11, a profile launch with no models.yml
      # routed to openrouter and died 402 "requires more credits" while
      # the status line still said Qwen. The qwen-only file is the
      # first gate; the overlay keys below are the rest.
      #
      # qwen-only gates (defense in depth — the fresh auth store alone
      # cannot cover env-var keys such as OPENROUTER_API_KEY inherited
      # from a shell that previously ran `omp`):
      #   enabledModels     — chat selection (startup model, /model
      #                       picker, Ctrl+P cycling) scoped to the one
      #                       model.
      #   disabledProviders — removes backends from selection even when
      #                       credentials exist. Covers the env-var-
      #                       backed cloud ids observed on this host
      #                       plus the implicit KEYLESS local probes
      #                       (ollama/llama.cpp/lm-studio are keyless,
      #                       hence available with zero credentials —
      #                       this replaces config.default.yml's
      #                       [llama.cpp] entry; arrays replace, not
      #                       append).
      #   retry.modelFallback — false: a pinned role whose engine is
      #                       down (`ashalliants-up`) must FAIL LOUDLY,
      #                       never leak a turn to a cloud model (no
      #                       fallbackChains by design — same intent).
      #
      # no-memory keys (overlay beats config.default.yml's mnemopi
      # backend and the enabled autolearn nudge):
      #   memory.backend: off — no Mnemopi long-term memory
      #   autolearn.enabled: false — no post-stop lesson/skill capture
      #
      # Non-chat roles (image/speech/dictation/web, tiny, memory) are
      # deliberately absent: no local engine serves those kinds, and
      # pinning them to qwen3.8-27b would just 404 or hallucinate
      # capabilities. `judge` accepts chat models, so it is pinned;
      # `commit`/`task` are ordinary chat roles (auto-resolve from
      # default when unset, but pinned for determinism). `:high` is
      # this model's top effort — the catalog has no `max` for it
      # (minimal/low/medium/high only; verified against `omp models`
      # + engine logs 2026-10-11).
      omplOverlay = {
        modelRoles = {
          default = "ashalliants/qwen3.8-27b:high";
          smol = "ashalliants/qwen3.8-27b:high";
          slow = "ashalliants/qwen3.8-27b:high";
          vision = "ashalliants/qwen3.8-27b:high";
          plan = "ashalliants/qwen3.8-27b:high";
          commit = "ashalliants/qwen3.8-27b:high";
          task = "ashalliants/qwen3.8-27b:high";
          advisor = "ashalliants/qwen3.8-27b:high";
          judge = "ashalliants/qwen3.8-27b:high";
        };

        enabledModels = [ "ashalliants/qwen3.8-27b" ];

        disabledProviders = [
          # implicit keyless local probes
          "ollama"
          "llama.cpp"
          "lm-studio"
          "apple"
          # env-var/stored-credential cloud ids observed on this host
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

      # Profile-local qwen-only models.yml. Reuses local.ashalliants
      # (single source of the provider block). On the default
      # generation :8092 is simply down and ompl fails loudly — as
      # designed, same as `ashalliants-up` gating the shared provider.
      omplModels = {
        providers.ashalliants = local.ashalliants;
      };

      # A named profile's agent dir resolves ITS OWN extensions/ and
      # keybindings.yml — the shared aspect's copies in ~/.omp/agent/
      # are invisible to it (verified 2026-10-11: no "[pi-reasonix]
      # Loaded" line under --profile with an empty profile dir). So the
      # profile gets its own: pi-reasonix (cache-first prefix work, cost
      # metrics) and the ctrl+v pasteImage remap (app.clipboard.pasteImage
      # -> alt+v, 2026-09-25 user bug: image chip instead of paste).
      #
      # Re-derived here rather than plucked from osConfig's
      # environment.systemPackages: the homeManager aspect's osConfig
      # does not carry systemPackages (findFirst returned null — build
      # error 2026-10-11). Same fetchurl+hash as the shared aspect
      # (oh-my-pi.nix:24-53), so content cannot diverge; keep the
      # version in sync.
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
      home.file.".omp/agent/models.yml".source =
        yaml.generate ".omp.agent.models.yml" models;

      # PI_CONFIG_FILES overlay (merged OVER config.yml/config.default.yml;
      # later overlays win), see the omplOverlay comment above.
      home.file.".omp/agent/ompl.yml".source =
        yaml.generate ".omp.agent.ompl.yml" omplOverlay;

      # --- ompl profile support files (~/.omp/profiles/ompl/agent/) ---
      home.file.".omp/profiles/ompl/agent/models.yml".source =
        yaml.generate ".omp.agent.ompl-models.yml" omplModels;

      home.file.".omp/profiles/ompl/agent/keybindings.yml".text = ''
        keybindings:
          app.clipboard.pasteImage: "alt+v"
      '';

      home.file.".omp/profiles/ompl/agent/extensions/pi-reasonix.js".source =
        "${reasonixPkg}/share/omp/extensions/pi-reasonix.js";

      home.shellAliases = {
        omp = ''
          CODEV_API_KEY="$(cat ${osConfig.age.secrets."codev-api-key".path})" \
          ORCAROUTER_API_KEY="$(cat ${osConfig.age.secrets."orcarouter-api-key".path})" \
          OPENCODE_API_KEY="$(cat ${osConfig.age.secrets."opencode-api-key".path})" \
          OPENROUTER_API_KEY="$(cat ${osConfig.age.secrets."openrouter-api-key".path})" \
          TABIAI_API_KEY="$(cat ${osConfig.age.secrets."tabiai-api-key".path})" \
          REASONIX_SCAVENGE=1 \
          REASONIX_RESULT_CAP_TOKENS=3000 \
          ${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp}/bin/omp'';

        # Same omp binary plus `--profile ompl`: isolated agent dir
        # (see the omplOverlay comment — no shared sessions/history/
        # auth, i.e. no persistence) and the qwen-only overlay. NO
        # secret exports: auth is none (local engine) and no cloud
        # provider is reachable, so there is nothing to authenticate.
        # Kept as a separate alias (the shared aspect owns `omp` via
        # mkDefault; the 5-secret export block above is duplicated by
        # design for `omp` — see its comment).
        ompl = ''
          PI_CONFIG_FILES="$HOME/.omp/agent/config.default.yml:$HOME/.omp/agent/ompl.yml" \
          ${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp}/bin/omp --profile ompl'';
      };
    };
  };
}
