{
  den,
  ...
}: {
   den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
     nixos = {pkgs, ...}: let
       # Upstream 0.33.3 silently drops model-authored speculative-decoding
       # PARAMETERs at Options.FromMap ("invalid option provided"), so the ngram
       # half of e.g. smtek/Swift-Qwen3.8-27B:map-k4v never reaches llama-server.
       # Patch forwards draft_spec_type / draft_ngram_map_k4v_* verbatim; see
       # patches/ollama-spec-params-passthrough.patch.
       ollama-cuda = pkgs.unstable.ollama-cuda.overrideAttrs (old: {
         patches = (old.patches or []) ++ [../../../../../../patches/ollama-spec-params-passthrough.patch];
       });
     in {
       # ollama (127.0.0.1:11434) is the only local inference daemon;
       # llama-cpp stays installed CLI-only (see llama-cpp.nix).
       services.ollama = {
         enable = true;
        package = ollama-cuda;

        # 0.0.0.0 + firewall scoped to tailscale0: DELL reaches ollama over
        # the tailnet (moonlight-era plan: DELL consumes legion's ollama via
        # tailscale, 2026-09-16). Binding the tailscale IP itself (100.x)
        # races tailscaled at boot — systemd start order can't guarantee the
        # address exists when ollama binds, and a bind failure loops the
        # unit; wildcard bind + nftables interface scoping is the boring
        # equivalent (verified: nftables aspect enabled on this host).
        host = "0.0.0.0";
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
          # https://markaicode.com/ollama-environment-variables-configuration-guide/#:~:text=Use%20OLLAMA%5FKEEP%5FALIVE%3D-1%20for%20a%20dedicated%20single%2Dmodel%20server%2E%20Use%200%20when%20memory%20is%20tight%20and%20requests%20are%20infrequent
          OLLAMA_KEEP_ALIVE = "-1";
          # OLLAMA_LOAD_TIMEOUT = "5m";

          # Pin to the 3090 ONLY (2026-09-20 fix for "27B models return
          # 404"/no-output): without it ollama's fit-params sees BOTH GPUs,
          # GPU1 (3060, 4 GiB free under bonsai2) drags the split down to
          # 34/66 layers on the 3090 + 32 layers on CPU RAM — 1.6 tok/s
          # decode (journal: "offloaded 34/66 layers to GPU",
          # "cannot meet free memory targets on all devices, need to use
          # 10238 MiB less"). Loads "succeed" but are so slow clients time
          # out. With this env the full model offloads to the 3090
          # (journal: 66/66) and the 3060 stays exclusive to bonsai2
          # (whose pin lives in /run/egpu/bonsai.env).
          #
          # Explicit UUID, not index "0": CUDA enumerates the 3060 first
          # (live check 2026-09-20: index 0 = 3060 a81782bc, index 1 = 3090
          # a4e36250), so "0" would pin the 6 GB 3060 — 27B cannot fit.
          # UUID is also enumerate-order-stable across reboots/dock states.
          # DOCK-ONLY TRADE-OFF: undocked (no 3090) ollama.service fails to
          # start on this pin; use `llamacpp-prism-up` for local inference
          # then (bonsai2 falls back to the 3060 via bonsai.env).
          CUDA_VISIBLE_DEVICES = "GPU-a4e36250-873d-62c5-912e-fde18d238a6c";
          OLLAMA_FLASH_ATTENTION = "1";
          # q8_0 KV over q4_0: the hybrid DeltaNet KV cache is tiny
          # (~2.1GB q8_0 at 64k), q4_0 saves ~0.5GB and costs quality.
          OLLAMA_KV_CACHE_TYPE = "q8_0";
          # OLLAMA_NOHISTORY = 0;
          # OLLAMA_NOPRUNE = 0;
          # 65536, not 131072 (2026-09-20 live test): at 131072 the 27B's
          # KV + compute overshoot the 3090 once bonsai-style fixed
          # allocations are counted — fit-params dropped to 63/66 layers
          # (1.4 GiB still CPU-mapped, 19.4 GiB free→-1.68 GiB overflow at
          # full fill) and the first load attempt logged 0/66 layers
          # (common_params_fit_impl "cannot meet free memory targets").
          # 64K keeps the model fully on the 3090 with headroom; raise
          # OLLAMA_CONTEXT_LENGTH only when bonsai2 is swapped out.
          OLLAMA_CONTEXT_LENGTH = "65536";
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

      # DELL consumes ollama over the tailnet (see host = "0.0.0.0" above):
      # open 11434 ONLY on tailscale0, never the LAN. networking.firewall
      # merges fine with the sunshine/ssh aspects' port lists.
      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [11434];

      # REMOVED 2026-09-20 (homelab specialisation): it existed to swap the
      # GPU pin per-boot, but the pin mechanism moved to
      # /run/egpu/bonsai.env (bonsai2 only) + the static 3090 UUID pin for
      # ollama above; the empty stub was dead config.

      # GPU pin: seeded by tmpfiles with the 3060 fallback, rewritten by
      # egpu-adopt/egpu-release on dock transitions (same pattern llama-cpp
      # used). ollama.service stays restartable via systemctl try-restart.
      # OBSOLETE 2026-09-20: ollama is now pinned via
      # services.ollama.environmentVariables.CUDA_VISIBLE_DEVICES (static
      # 3090 UUID); the pin file /run/egpu/bonsai.env belongs to bonsai2
      # only (see bonsai2.nix and firmware/egpu.nix).
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
