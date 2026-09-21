{
  den,
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

      # 3090 gating (2026-09-21, hotspot.nix pattern): the local ollama
      # provider (:11434) exists ONLY inside the homelab specialisation —
      # the daemon it points at is gated there too (ollama.nix). osConfig.isSpecialisation is mkOverride-0
      # true inside spec evals (nixos/modules/system/activation/no-clone.nix)
      # and false in the default generation, so the two models.yml variants
      # diverge on this flag and there is no module collision (the spec HM
      # eval replaces the default HM config wholesale).
      onHomelabSpec = osConfig.isSpecialisation or false;

      cloudProviders = {
        # https://docs.orcarouter.ai/integrations/oh-my-pi
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
          modelOverrides."hf.co/bartowski/Altworld_Hemmingway-1-GGUF:Q4_K_M" = {
            contextWindow = 131072;
            maxTokens = 16384;
          };
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

      defaultConfig = {
        # The ollama qwen3.8 models are selectable via /model; roles stay in
        # the mutable config.yml (PI_CONFIG_FILES merges this OVER it).
        # modelRoles = {
        #   default = "ollama/qwen3.8:27b-mtp-q4_K_M:max";
        # };

        symbolPreset = "nerd";

        composer = {
          shape = "box";
        };

        theme = {
          dark = "dark-rainforest";
          light = "light-forest";
        };

        setupVersion = 2;

        astGrep = {
          enabled = true;
        };

        github = {
          enabled = true;
        };

        edit = {
          mode = "hashline";
        };

        memory = {
          backend = "mnemopi";
        };

        defaultThinkingLevel = "max";

        retry = {
          usageAwareFallback = false;
          fallbackRevertPolicy = "cooldown-expiry";
        };

        advisor = {
          enabled = true;
          syncBacklog = "off";
        };

        autolearn = {
          enabled = true;
          autoContinue = true;
        };

        followUpMode = "one-at-a-time";
        interruptMode = "immediate";

        tools = {
          approvalMode = "yolo";
        };

        error = {
          notify = "on";
        };

        update = {
          channel = "stable";
        };

        power = {
          sleepPrevention = "idle";
        };

        features = {
          unexpectedStopDetection = "smart";
        };

        colorBlindMode = false;

        statusLine = {
          preset = "default";
          separator = "powerline-thin";
          contextLine = "embedded";
          sessionAccent = false;
          transparent = false;
          compactThinkingLevel = true;
          showHookStatus = true;
        };

        terminal = {
          showProgress = true;
        };

        tui = {
          textSizing = true;
          codexResetFireworks = true;
          tight = false;
          hyperlinks = "always";
        };

        display = {
          shimmer = "classic";
          smoothStreaming = true;
          showTokenUsage = true;
          showTurnTime = true;
          cacheMissMarker = true;
        };

        task = {
          showResolvedModelBadge = true;
        };

        images = {
          blockImages = false;
        };

        modelRoleStorage = "global";
        personality = "default";

        prewalk = {
          enabled = false;
        };

        loop = {
          mode = "compact";
        };

        contextPromotion = {
          enabled = false;
        };
      };
      # TODO "homelab" specialization: homelabConfig was deleted unused
      # (2026-09-21); re-add it together with its consumer when needed.
    in {
      home.file.".omp/agent/models.yml".source =
        yaml.generate ".omp.agent.models.yml" models;

      # NOT ".omp/agent/config.yml": omp treats that file as mutable state
      # (writes setupVersion, /model picks, wizard results) and saving through
      # an HM store symlink dies with EROFS, which re-triggers the setup wizard
      # on every launch. This file is a read-only overlay merged OVER
      # config.yml via PI_CONFIG_FILES (set in the omp alias below).
      home.file.".omp/agent/config.default.yml".source =
        yaml.generate ".omp.agent.config.default.yml" defaultConfig;

      # TODO "homelab" specialization
      # home.file.".omp/agent/config.homelab.yml".source =
      #   yaml.generate ".omp.agent.config.homelab.yml" homelabConfig;

      home.shellAliases = {
        omp = ''
          CODEV_API_KEY="$(cat ${osConfig.age.secrets."codev-api-key".path})" \
          ORCAROUTER_API_KEY="$(cat ${osConfig.age.secrets."orcarouter-api-key".path})" \
          OPENCODE_API_KEY="$(cat ${osConfig.age.secrets."opencode-api-key".path})" \
          OPENROUTER_API_KEY="$(cat ${osConfig.age.secrets."openrouter-api-key".path})" \
          TABIAI_API_KEY="$(cat ${osConfig.age.secrets."tabiai-api-key".path})" \
          REASONIX_SCAVENGE=1 \
          REASONIX_RESULT_CAP_TOKENS=3000 \
          PI_CONFIG_FILES="$HOME/.omp/agent/config.default.yml" \
          ${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp}/bin/omp
        '';
      };
    };
  };
}
