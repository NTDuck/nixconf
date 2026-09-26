{
  den,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    homeManager = {
      osConfig,
      pkgs,
      ...
    }: let
      yaml = pkgs.formats.yaml {};

      # 3090 gating (2026-09-21, 3090 specialisation pattern): the local ollama
      # provider (:11434) exists ONLY inside the homelab specialisation —
      # the daemon it points at is gated there too (ollama.nix). osConfig.isSpecialisation is mkOverride-0
      # true inside spec evals (nixos/modules/system/activation/no-clone.nix)
      # and false in the default generation, so the two models.yml variants
      # diverge on this flag and there is no module collision (the spec HM
      # eval replaces the default HM config wholesale).
      onHomelabSpec = osConfig.isSpecialisation or false;

      cloudProviders = {
        # DISABLED 2026-09-26 (user decision): secrets/orcarouter-api-key.age
        # decrypts to 0 bytes (saved empty by a past `agenix -e`) and the key
        # itself is unrecoverable — the common harness's fail-fast guard
        # (26d6ee1) would abort EVERY omp launch on the empty secret. Re-add
        # this block (and models entry below) after `agenix -e
        # secrets/orcarouter-api-key.age` with the real key.
        # https://docs.orcarouter.ai/integrations/oh-my-pi
        # orcarouter = {
        #   baseUrl = "https://api.orcarouter.ai/v1";
        #   api = "openai-completions";
        #   apiKey = "ORCAROUTER_API_KEY";
        #   authHeader = true;
        #
        #   models = [
        #     {
        #       id = "orcarouter/auto";
        #       name = "OrcaRouter";
        #       reasoning = false;
        #       input = ["text"];
        #       contextWindow = 200000;
        #       maxTokens = 8192;
        #
        #       compat = {
        #         supportsDeveloperRole = false;
        #         maxTokensField = "max_tokens";
        #       };
        #     }
        #   ];
        # };

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

            {
              id = "zai-org/GLM-5.3-Flash";
              name = "GLM 5.3 Flash (NetMind)";
              contextWindow = 1048576;
              maxTokens = 131072;
            }
          ];
        };
      };

      # 3090-coupled local providers — homelab spec only (see onHomelabSpec).
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

      # config.default.yml (shared omp TUI defaults) and the `omp` alias
      # (secret exports + PI_CONFIG_FILES wrapper) moved to the COMMON
      # aspect modules/features/dev/agentics/harnesses/oh-my-pi.nix
      # (2026-09-22): dell gets the same defaults/alias, and a second
      # bare `omp =` definition here would collide with the common one
      # at eval (attrset leaf values need a single definition). The
      # commented modelRoles block went with it — roles belong in the
      # mutable config.yml, and the comment lives on in the common file.
    in {
      home.file.".omp/agent/models.yml".source =
        yaml.generate ".omp.agent.models.yml" models;
    };
  };
}
