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

      models = {
        providers = {
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
          # Keyless local engine: explicit entry replaces implicit discovery
          # but keeps ollama discovery. modelOverrides pins qwen3.8:27b to
          # what the daemon actually serves (vram-based default 32768 on the
          # 3090; see ollama.nix): omp's bundled ollama catalog claims
          # contextWindow 262144 / maxTokens 32768, so omp keeps sending
          # past the real window and ollama's trim drops the original user
          # turn — every agentic tool-loop continuation then 500s with "no
          # user query found in messages" (ollama #17778, reproduced
          # 2026-09-15 via curl: tool-last + over-ctx = 500, under-ctx =
          # 200) and the retry loop re-sends the identical payload forever.
          # Pinning the window makes omp compact ~20K instead; maxTokens
          # keeps the output cap sane inside the window.
          ollama = {
            baseUrl = "http://127.0.0.1:11434";
            api = "openai-responses";
            auth = "none";
            discovery.type = "ollama";
            modelOverrides."qwen3.8:27b-mtp-q4_K_M" = {
              # 128k to match OLLAMA_CONTEXT_LENGTH (q4_0 KV makes 131072
              # fit the 3090; see ollama.nix).
              contextWindow = 131072;
              maxTokens = 16384;
            };
          };

          # Bonsai 2 27B via the PrismML fork's llama-server (bonsai2.service,
          # :8080; see bonsai2.nix for why ollama cannot run this model).
          # openai-completions, NOT openai-responses: llama-server serves
          # /v1/chat/completions only. contextWindow pins what the unit
          # launches with (-c 196608, 2026-09-20 raise from 32768); maxTokens
          # stays 16384 to keep peak VRAM inside the 3090's budget (see the
          # models entry below).
          bonsai = {
            baseUrl = "http://127.0.0.1:8080";
            api = "openai-completions";
            auth = "none";
            models = [
              {
                id = "bonsai2";
                name = "Ternary Bonsai 2 27B (local)";
                contextWindow = 196608;
                # Deliberately 16384: peak decode KV = maxTokens * 64 KiB/token
                # (see bonsai2.nix) = 1 GiB on top of the 11.25 GiB input KV +
                # 6.71 GiB PQ2_0 weights — 192K/16K peaks ~19.4 GiB on the
                # 24.5 GB 3090; a 64K output cap would push ~23.5 GiB with
                # <1 GiB headroom.
                maxTokens = 16384;
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
      };

      defaultConfig = {
        # Daily driver switched to Bonsai 2 27B (bonsai2.service :8080,
        # 2026-09-18). PI_CONFIG_FILES merges this OVER the mutable
        # config.yml, so this beats whatever /model last picked. The
        # ollama qwen3.8 models stay pulled and selectable via /model.
        # modelRoles = {
        #   default = "bonsai/bonsai2:max";
        #   smol = "bonsai/bonsai2:low";
        #   plan = "bonsai/bonsai2:xhigh";
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
