{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    # ENTIRE 3090 INFERENCE STACK IS HOMELAB-ONLY (2026-09-21 user request):
    # every service/package here lives inside specialisation.homelab
    # (3090 specialisation pattern — specialisation.X.configuration merges over the
    # inherited parent config, and options NOT set in the default generation
    # don't exist there). Boot the default spec and ollama/the CUDA builds
    # are absent; pick "homelab" in the bootloader menu for inference.
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
      specialisation.homelab.configuration = {
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
            # OFFICIAL tag MUST be declared (2026-09-26): syncModels = true
            # regex-removes every installed model NOT in this list
            # (ollama-module script: `undeclared=$(... /regex/d); ollama rm`).
            # The official tag was undeclared, so the loader deleted it, and
            # omp's bundled catalog + user sessions still address
            # qwen3.8:27b -> 404 "model not found" (journal 2026-09-21,
            # 6x). Registry verified 200 before adding.
            "qwen3.8:27b"
            "qwen3.8:27b-mtp-q4_K_M"
            "jetelain/Qwen3.8-27B:latest" # Unsloth Dynamic V3.0 GGUFs, UD-Q4_K_XL, 128k
            "mannix/omnimerge-v6:vision-Q4_K_M" # Weight tuned from qwen3.8:27b, vision
            "orcarouter/Qwen3.8-27B-Uncensored:q4_K_M" # Abliterated
            "smtek/Swift-Qwen3.8-27B:dflash2" # Block-diffusion draft model
            "smtek/Swift-Qwen3.8-27B:map-k4v" # Engram
            # Hemmingway-1 (2026-09-21): 27B Qwen3.8-27B finetune specialized
            # for everyday human communication/writing (EQ-Bench 4 ~1330).
            # Same qwen35 hybrid-SSM arch as the qwen3.8:27b entries (GGUF
            # header: ssm.* + full_attention_interval), so the 128k/q4_0-KV
            # budget math carries over: Q4_K_M weights 16.24 GiB + ~1.45 GiB
            # KV ~= 18 GiB of the 3090's 24.5 -> full offload on an empty
            # 3090. Catalog overclaims contextWindow 262144 like every
            # qwen3.8 quant; the omp override below pins the real daemon
            # window (ollama #17778 500-loop hazard).
            # LOWERCASE q (2026-09-26): ollama stores/returns the tag as
            # `:q4_K_M` — the syncModels prune regex is CASE-SENSITIVE, so
            # the old `:Q4_K_M` here made the loader delete the installed
            # lowercase tag on every activation (observed live in the
            # ollama-model-loader journal, 12:29). Must match /api/tags
            # verbatim, same as the modelOverrides key.
            "hf.co/bartowski/Altworld_Hemmingway-1-GGUF:q4_K_M"

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
            # Auto-unload after 5 idle minutes (2026-09-25 user request):
            # models release the 3090 when nobody talks to the daemon, and
            # the next request pays a cold load. "-1" (pin forever) was the
            # swap-era setting when bonsai2 arbitration needed a resident
            # winner; with the 3090 now shared again (prism stack is back)
            # an evergreen resident just starves the other daemon.
            OLLAMA_KEEP_ALIVE = "5m";
            # OLLAMA_LOAD_TIMEOUT = "5m";

            # Pin to the 3090 ONLY (2026-09-20 fix for "27B models return
            # 404"/no-output): without it ollama's fit-params sees BOTH GPUs
            # (3060 + 3090) and drags the split down to 34/66 layers on the
            # 3090 + 32 layers on CPU RAM — 1.6 tok/s decode (journal:
            # "offloaded 34/66 layers to GPU", "cannot meet free memory
            # targets on all devices, need to use 10238 MiB less"). Loads
            # "succeed" but are so slow clients time out. With this env the
            # full model offloads to the 3090 (journal: 66/66).
            #
            # Explicit UUID, not index "0": CUDA enumerates the 3060 first
            # (live check 2026-09-20: index 0 = 3060 a81782bc, index 1 = 3090
            # a4e36250), so "0" would pin the 6 GB 3060 — 27B cannot fit.
            # UUID is also enumerate-order-stable across reboots/dock states.
            # DOCK-ONLY TRADE-OFF: undocked (no 3090) ollama.service fails to
            # start on this pin.
            # Re-enabled 2026-09-25 (user request: homelab spec shows the
            # 3090 only); the 34/66 hazard is real and CUDA_VISIBLE_DEVICES
            # on the unit is the proven guard.
            CUDA_VISIBLE_DEVICES = "GPU-a4e36250-873d-62c5-912e-fde18d238a6c";
            OLLAMA_FLASH_ATTENTION = "1";
            # q4_0 KV (revisit of the earlier q8_0 call, 2026-09-20 live fit):
            # at 131072 ctx the hybrid DeltaNet KV is ~2.9 GiB q8_0 and the
            # fit fell 707 MiB short of 66/66 layers (63/66, 1.4 GiB CPU
            # tail). q4_0 halves the KV (~1.45 GiB) → 66/66 with margin.
            # SSM-cache layers dominate anyway; per-layer full-attn KV is
            # 1/4 of layers (full_attention_interval=4).
            OLLAMA_KV_CACHE_TYPE = "q4_0";
            # OLLAMA_NOHISTORY = 0;
            # OLLAMA_NOPRUNE = 0;
            # 131072 (2026-09-20, q4_0 KV): 128k is the floor per user. With
            # q8_0 KV the fit fell 707 MiB short of 66/66 layers at 131072
            # (63/66, 1.4 GiB CPU tail). q4_0 KV closes the gap with ~700
            # MiB spare; full 66/66 offload needs an EMPTY 3090.
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

        # DELL consumes ollama over the tailnet (see host = "0.0.0.0" above):
        # open 11434 ONLY on tailscale0, never the LAN. networking.firewall
        # merges fine with the sunshine/ssh aspects' port lists.
        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [11434];
      }; # specialisation.homelab.configuration
    };
  };
}
