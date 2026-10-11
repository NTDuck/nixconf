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
{
  inputs,
  ...
}: {
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

        freetoken = {
          baseUrl = "http://127.0.0.1:1919/v1";
          api = "openai-completions";
          apiKey = "freetoken";

          models = [
            {
              id = "Qwen/Qwen3-30B-A3B";
              name = "Qwen3 30B A3B (FreeToken)";
              reasoning = true;
              input = ["text"];
              contextWindow = 131072;
              maxTokens = 8192;
            }

            {
              id = "Qwen/Qwen3.6-35B-A3B";
              name = "Qwen3.6 35B A3B (FreeToken)";
              reasoning = true;
              input = ["text"];
              contextWindow = 131072;
              maxTokens = 8192;
            }

            {
              id = "Qwen/Qwen3.5-35B-A3B";
              name = "Qwen3.5 35B A3B (FreeToken)";
              reasoning = true;
              input = ["text"];
              contextWindow = 131072;
              maxTokens = 8192;
            }

            {
              id = "openai/gpt-oss-20b";
              name = "GPT-OSS 20B (FreeToken)";
              reasoning = true;
              input = ["text"];
              contextWindow = 131072;
              maxTokens = 8192;
            }

            {
              id = "openai/gpt-oss-120b";
              name = "GPT-OSS 120B (FreeToken)";
              reasoning = true;
              input = ["text"];
              contextWindow = 131072;
              maxTokens = 8192;
            }

            {
              id = "deepseek-ai/DeepSeek-V4-Flash-0731";
              name = "DeepSeek V4 Flash (FreeToken)";
              reasoning = true;
              input = ["text"];
              contextWindow = 131072;
              maxTokens = 8192;
            }

            {
              id = "google/gemma-4-26B-A4B-it";
              name = "Gemma 4 26B A4B (FreeToken)";
              reasoning = true;
              input = ["text"];
              contextWindow = 131072;
              maxTokens = 8192;
            }

            {
              id = "nvidia/GLM-5.2-NVFP4";
              name = "GLM 5.2 NVFP4 (FreeToken)";
              reasoning = true;
              input = ["text"];
              contextWindow = 131072;
              maxTokens = 8192;
            }

            {
              id = "nvidia/GLM-4.7-NVFP4";
              name = "GLM 4.7 NVFP4 (FreeToken)";
              reasoning = true;
              input = ["text"];
              contextWindow = 131072;
              maxTokens = 8192;
            }

            {
              id = "nvidia/MiniMax-M2.5-NVFP4";
              name = "MiniMax M2.5 NVFP4 (FreeToken)";
              reasoning = true;
              input = ["text"];
              contextWindow = 131072;
              maxTokens = 8192;
            }

            {
              id = "meta-models/Muse-Glimmer-30B";
              name = "Muse Glimmer 30B (FreeToken)";
              reasoning = true;
              input = ["text"];
              contextWindow = 131072;
              maxTokens = 8192;
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

        # Ternary Bonsai 2 27B (prism llama-server, :8080 — see
        # ../prism/default.nix). discovery.type = "llama.cpp" makes omp
        # poll GET /models + GET /props; contextWindow comes from
        # meta.n_ctx in /v1/models (sniffs --ctx-size 262144 via
        # status.args / props default_generation_settings.n_ctx —
        # no modelOverrides needed). Provider name is dot-free
        # "bonsai2": omp fixups key off discovery.type (not the id) and
        # pkgs.formats.yaml splits a dotted attr into nested maps
        # (2026-09-26). The implicit built-in "llama.cpp" discoverable is
        # disabled in the shared defaultConfig to avoid a duplicate
        # listing. auth "none" keeps it keyless (server binds 127.0.0.1
        # only).
        bonsai2 = {
          baseUrl = "http://127.0.0.1:8080";
          api = "openai-responses";
          auth = "none";
          discovery.type = "llama.cpp";
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

      # `ompl` = omp with every chat model role pinned to the local
      # ashalliants Qwen3.8-27B engine (:8092, ../ashalliants.nix), so
      # /model cycling, subagents, and the advisor all stay on the 3090
      # instead of falling back to cloud providers. Selector precedence
      # (omp://settings.md): CLI overlays (PI_CONFIG_FILES) override the
      # global config.yml, so this layer beats /model role picks. `:high`
      # is this model's top effort — the catalog has no `max` for it
      # (minimal/low/medium/high only; verified against `omp models`
      # + engine logs 2026-10-11, `:max` runs the default template
      # unchanged). Non-chat roles (image/speech/dictation/web, tiny,
      # memory) are deliberately absent: no local engine serves those
      # kinds, and pinning them to qwen3.8-27b would just 404 or
      # hallucinate capabilities. `judge` accepts chat models, so it is
      # pinned; `commit`/`task` are ordinary chat roles (auto-resolve
      # from default when unset, but pinned for determinism). No
      # fallbackChains: a role pinned to the local engine must fail
      # loudly when the engine is down (`ashalliants-up`), not
      # silently leak a turn to a cloud provider.
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
      };
    in {
      home.file.".omp/agent/models.yml".source =
        yaml.generate ".omp.agent.models.yml" models;

      # models.yml REPLACES omp's implicit catalog (see the ollama block
      # above), so cloud providers exist only through the declaration
      # below — the overlay cannot re-enable them by omission.
      home.file.".omp/agent/ompl.yml".source =
        yaml.generate ".omp.agent.ompl.yml" omplOverlay;

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

        # Same wrapper as `omp` plus the role-pinning overlay appended to
        # PI_CONFIG_FILES (later overlays override earlier ones, and both
        # override the mutable config.yml — so /model role picks cannot
        # leak a cloud model into an ompl session). Kept as a separate
        # alias, not an override of `omp`: the shared aspect owns `omp`
        # via mkDefault and the 5-secret export block is duplicated here
        # by design (the existing comment on `omp` documents why the
        # legion alias is a full literal).
        ompl = ''
          CODEV_API_KEY="$(cat ${osConfig.age.secrets."codev-api-key".path})" \
          ORCAROUTER_API_KEY="$(cat ${osConfig.age.secrets."orcarouter-api-key".path})" \
          OPENCODE_API_KEY="$(cat ${osConfig.age.secrets."opencode-api-key".path})" \
          OPENROUTER_API_KEY="$(cat ${osConfig.age.secrets."openrouter-api-key".path})" \
          TABIAI_API_KEY="$(cat ${osConfig.age.secrets."tabiai-api-key".path})" \
          REASONIX_SCAVENGE=1 \
          REASONIX_RESULT_CAP_TOKENS=3000 \
          PI_CONFIG_FILES="$HOME/.omp/agent/config.default.yml:$HOME/.omp/agent/ompl.yml" \
          ${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp}/bin/omp'';
      };
    };
  };
}
