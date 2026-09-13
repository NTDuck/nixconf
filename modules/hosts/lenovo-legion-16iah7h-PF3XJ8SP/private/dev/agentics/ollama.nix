{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      config,
      pkgs,
      ...
    }: {
      # ollama (127.0.0.1:11434) is the only local inference daemon;
      # llama-cpp stays installed CLI-only (see llama-cpp.nix).
      services.ollama = {
        enable = true;
        package = pkgs.unstable.ollama-cuda;

        host = "127.0.0.1";
        port = 11434;

        loadModels = [
          # eGPU (RTX 3090): flagship local general model (official qwen3.8)
          "qwen3.8:27b"

          # reasoning: MoE thinking model
          "qwen3:30b-a3b-thinking-2507-q4_K_M"
          # coding: small instruct model, fits the laptop 3060
          "hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:UD-Q4_K_XL"
          # uncensored Heretic finetune for the 3090 — chosen for ungated
          # pull + benchmark-preserved capabilities (mean delta -0.5pp).
          # Its renderer clone below clone appends the homelab suffix to this
          # tag, so syncModels' regex match keeps both.
          "hf.co/JonathanColetti/Qwen3.8-27B-Uncensored-GGUF:Q4_K_M"
        ];

        syncModels = true;

        environmentVariables = {
          OLLAMA_FLASH_ATTENTION = "1";
          # q8_0 KV over q4_0: the hybrid DeltaNet KV cache is tiny
          # (~2.1GB q8_0 at 64k), q4_0 saves ~0.5GB and costs quality.
          OLLAMA_KV_CACHE_TYPE = "q8_0";
          # keep the 27B resident.
          OLLAMA_KEEP_ALIVE = "-1";
          # 64k for agentic tool loops.
          OLLAMA_CONTEXT_LENGTH = "65536";
          OLLAMA_NUM_PARALLEL = "1";
          OLLAMA_MAX_LOADED_MODELS = "2";
        };
      };

      # GPU pin: seeded by tmpfiles with the 3060 fallback, rewritten by
      # egpu-adopt/egpu-release on dock transitions (same pattern llama-cpp
      # used). ollama.service stays restartable via systemctl try-restart.
      systemd.services.ollama = {
        serviceConfig.EnvironmentFile = "/run/egpu/ollama.env";
      };

      systemd.tmpfiles.rules = [
        "d /run/egpu 0755 root root -"
        # 3060 laptop fallback; 'f' (not 'f+') so a mid-session 3090 pin
        # written by egpu-adopt survives a rebuild.
        "f /run/egpu/ollama.env 0644 root root - CUDA_VISIBLE_DEVICES=GPU-a81782bc-e6d4-e015-445a-d413a0e94529"
      ];

      # ollama #17778: the qwen3.8 renderer 500s with "no user query found
      # in messages" when context truncation drops the user turn or on
      # tool-only turns. Cloning with renderer=qwen3.5 overrides only the
      # renderer — same weights, tolerant renderer, thinking+tools intact.
      # Clones are created once via the HTTP API; this oneshot is idempotent
      # (skips tags already present) so rebuilds are no-ops. Clone tags
      # match/superset the loadModels names so syncModels pruning keeps them.
      systemd.services.ollama-renderer-clones = {
        description = "Create renderer-cloned ollama models (qwen3.5 renderer fix, ollama #17778)";
        wantedBy = ["multi-user.target"];
        after = [
          "ollama.service"
          "ollama-model-loader.service"
          "network-online.target"
        ];
        bindsTo = ["ollama.service"];
        wants = ["network-online.target" "ollama-model-loader.service"];

        path = [
          config.services.ollama.package
          pkgs.curl
          pkgs.jq
          pkgs.gawk
          pkgs.gnugrep
        ];

        environment.HOME = config.services.ollama.home;

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        script = ''
          set -eu

          have() {
            local m="$1"
            # `ollama list` normalizes a tagless name to name:latest.
            case "$m" in
              *:*) ;;
              *) m="$m:latest" ;;
            esac
            ollama list | awk '{print $1}' | grep -Fxq "$m"
          }

          create_clone() {
            local clone="$1" base="$2"
            if have "$clone"; then
              echo "clone $clone already present, skipping"
            else
              echo "creating clone $clone from $base"
              curl -sS http://127.0.0.1:11434/api/create \
                -d "$(printf '{"model":"%s","from":"%s","renderer":"qwen3.5"}' "$clone" "$base")"
              have "$clone" || { echo "clone $clone failed to appear"; exit 1; }
            fi
          }

          # Official qwen3.8:27b renderer clone. 'FROM X' + 'model X'
          # (same-tag clone) is fragile: ollama resolves the tag against
          # itself before the clone exists, so use a distinct tag. The tag
          # embeds the declared loadModels id "qwen3.8:27b" as a prefix so
          # syncModels' regex keeps it (tagless names get pruned).
          create_clone "qwen3.8:27b-qwen3-8-27b-homelab" "qwen3.8:27b"
          sleep 1

          # Same-shape clone off the uncensored blob: the tag is the
          # declared loadModels entry (regex-matched by syncModels), so
          # pruning keeps it.
          create_clone \
            "hf.co/JonathanColetti/Qwen3.8-27B-Uncensored-GGUF:Q4_K_M-qwen3-8-27b-homelab" \
            "hf.co/JonathanColetti/Qwen3.8-27B-Uncensored-GGUF:Q4_K_M"
          sleep 1

          # Same-tag re-render: clone replaces the official 4B tag in place
          # (FROM <itself> — ollama tolerates it on create); skipped by the
          # have() guard on every later boot.
          create_clone \
            "hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:UD-Q4_K_XL" \
            "hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:UD-Q4_K_XL"
        '';
      };
    };
  };
}
