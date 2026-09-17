{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {pkgs, ...}: {
      # ollama (127.0.0.1:11434) is the only local inference daemon;
      # llama-cpp stays installed CLI-only (see llama-cpp.nix).
      services.ollama = {
        enable = true;
        package = pkgs.unstable.ollama-cuda;

        host = "127.0.0.1";
        port = 11434;

        loadModels = [
          # Slayer of Opus 4.6!
          "qwen3.8:27b-mtp-q4_K_M"
          "jetelain/Qwen3.8-27B:latest" # Unsloth Dynamic V3.0 GGUFs, UD-Q4_K_XL, 128k
          "mannix/omnimerge-v6:vision-Q4_K_M" # Weight tuned from qwen3.8:27b, vision
          "orcarouter/Qwen3.8-27B-Uncensored:q4_K_M" # Abliterated
          "smtek/Swift-Qwen3.8-27B:dflash2" # Block-diffusion draft model
          "smtek/Swift-Qwen3.8-27B:map-k4v" # Engram

          "Distendo/zen-pro" # Unknown pull

          # Wonderful SLMs
          # Warning: [VRAM] 9GB at rest, ~41GB upon reaching 1M context window
          # On 3090 recommended is 16/32K?
          # https://www.mindstudio.ai/blog/spark-x25-4b-local-review
          "SparkLLM/Spark-X2.5-4B" # ^reasoning, coding
          "openbmb/minicpm5-2b:f16" # reasoning, ^coding'
          "openbmb/minicpm5-2b:q8_0" # More comfortable fit for 3060
          "lfm2.5:8b-a1b-bf16" # hallucination-resistant, tool-calling
          "granite4.1:3b-bf16" # hallucination-resistant, tool-calling
        ];

        syncModels = true;

        # https://github.com/ollama/ollama/blob/main/envconfig/config.go
        environmentVariables = {
          # https://markaicode.com/ollama-environment-variables-configuration-guide/#:~:text=Use%20OLLAMA%5FKEEP%5FALIVE%3D%2D1%20for%20a%20dedicated%20single%2Dmodel%20server%2E%20Use%200%20when%20memory%20is%20tight%20and%20requests%20are%20infrequent
          OLLAMA_KEEP_ALIVE = "-1";
          # OLLAMA_LOAD_TIMEOUT = "5m";

          OLLAMA_FLASH_ATTENTION = "1";
          # q8_0 KV over q4_0: the hybrid DeltaNet KV cache is tiny
          # (~2.1GB q8_0 at 64k), q4_0 saves ~0.5GB and costs quality.
          OLLAMA_KV_CACHE_TYPE = "q8_0";
          # OLLAMA_NOHISTORY = 0;
          # OLLAMA_NOPRUNE = 0;
          # keep the 27B resident.
          OLLAMA_CONTEXT_LENGTH = "131072";
          # OLLAMA_AUTH = 0;
          # OLLAMA_IGPU_ENABLE = 0;
          OLLAMA_NO_CLOUD = "1";
          # OLLAMA_CREATE_REMOTE = 0;

          OLLAMA_NUM_PARALLEL = "1";
          OLLAMA_MAX_LOADED_MODELS = "1";

          # What does this even do?
          OLLAMA_NEW_ENGINE = "1";
        };
      };

      specialisation.homelab.configuration = {
        services.ollama.environmentVariables = {
          # TODO Fill with 3090
          # CUDA_VISIBLE_DEVICES =
        };
      };

      # GPU pin: seeded by tmpfiles with the 3060 fallback, rewritten by
      # egpu-adopt/egpu-release on dock transitions (same pattern llama-cpp
      # used). ollama.service stays restartable via systemctl try-restart.
      # systemd.services.ollama = {
      #   serviceConfig.EnvironmentFile = "/run/egpu/ollama.env";
      # };

      # systemd.tmpfiles.rules = [
      #   "d /run/egpu 0755 root root -"
      #   # 3060 laptop fallback; 'f' (not 'f+') so a mid-session 3090 pin
      #   # written by egpu-adopt survives a rebuild.
      #   "f /run/egpu/ollama.env 0644 root root - CUDA_VISIBLE_DEVICES=GPU-a81782bc-e6d4-e015-445a-d413a0e94529"
      # ];

      # ollama #17778: the qwen3.8 renderer 500s with "no user query found
      # in messages" when context truncation drops the user turn or on
      # tool-only turns. Cloning with renderer=qwen3.5 overrides only the
      # renderer — same weights, tolerant renderer, thinking+tools intact.
      # Clones are created once via the HTTP API; this oneshot is idempotent
      # (skips tags already present) so rebuilds are no-ops. Clone tags
      # match/superset the loadModels names so syncModels pruning keeps them.
      # systemd.services.ollama-renderer-clones = {
      #   description = "Create renderer-cloned ollama models (qwen3.5 renderer fix, ollama #17778)";
      #   wantedBy = ["multi-user.target"];
      #   after = [
      #     "ollama.service"
      #     "ollama-model-loader.service"
      #     "network-online.target"
      #   ];
      #   bindsTo = ["ollama.service"];
      #   wants = ["network-online.target" "ollama-model-loader.service"];

      #   path = [
      #     config.services.ollama.package
      #     pkgs.curl
      #     pkgs.jq
      #     pkgs.gawk
      #     pkgs.gnugrep
      #   ];

      #   environment.HOME = config.services.ollama.home;

      #   serviceConfig = {
      #     Type = "oneshot";
      #     RemainAfterExit = true;
      #   };

      #   script = ''
      #     set -eu

      #     have() {
      #       local m="$1"
      #       # `ollama list` normalizes a tagless name to name:latest.
      #       case "$m" in
      #         *:*) ;;
      #         *) m="$m:latest" ;;
      #       esac
      #       ollama list | awk '{print $1}' | grep -Fxq "$m"
      #     }

      #     create_clone() {
      #       local clone="$1" base="$2"
      #       if have "$clone"; then
      #         echo "clone $clone already present, skipping"
      #       else
      #         echo "creating clone $clone from $base"
      #         curl -sS http://127.0.0.1:11434/api/create \
      #           -d "$(printf '{"model":"%s","from":"%s","renderer":"qwen3.5"}' "$clone" "$base")"
      #         have "$clone" || { echo "clone $clone failed to appear"; exit 1; }
      #       fi
      #     }

      #     # Official qwen3.8:27b renderer clone. 'FROM X' + 'model X'
      #     # (same-tag clone) is fragile: ollama resolves the tag against
      #     # itself before the clone exists, so use a distinct tag. The tag
      #     # embeds the declared loadModels id "qwen3.8:27b" as a prefix so
      #     # syncModels' regex keeps it (tagless names get pruned).
      #     create_clone "qwen3.8:27b-qwen3-8-27b-homelab" "qwen3.8:27b"
      #     sleep 1

      #     # Same-shape clone off the uncensored blob: the tag is the
      #     # declared loadModels entry (regex-matched by syncModels), so
      #     # pruning keeps it.
      #     create_clone \
      #       "hf.co/JonathanColetti/Qwen3.8-27B-Uncensored-GGUF:Q4_K_M-qwen3-8-27b-homelab" \
      #       "hf.co/JonathanColetti/Qwen3.8-27B-Uncensored-GGUF:Q4_K_M"
      #     sleep 1

      #     # Same-tag re-render: clone replaces the official 4B tag in place
      #     # (FROM <itself> — ollama tolerates it on create); skipped by the
      #     # have() guard on every later boot.
      #     create_clone \
      #       "hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:UD-Q4_K_XL" \
      #       "hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:UD-Q4_K_XL"
      #   '';
      # };
    };
  };
}
