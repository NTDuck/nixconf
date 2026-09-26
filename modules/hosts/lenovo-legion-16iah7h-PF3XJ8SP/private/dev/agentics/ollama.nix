{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    # ENTIRE 3090 INFERENCE STACK IS HOMELAB-ONLY (2026-09-21 user request):
    # every service/package here lives inside specialisation.homelab. Boot
    # the default spec and ollama/the CUDA builds are absent; pick "homelab"
    # in the bootloader menu for inference.
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
        # Bonsai2's unit declares Conflicts= against this one (see
        # ../prism/default.nix) — the 27B daemons arbitrate the 3090
        # via llamacpp-prism-up/-down (this custom module exposes no
        # conflicts option, so the reverse direction is script-driven).
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

          # loadModels + syncModels = an allowlist: the loader DELETES every
          # installed model not listed here. Entries must match /api/tags
          # verbatim (case included — the prune regex is case-sensitive; a
          # mismatched tag makes the loader delete the installed variant on
          # every activation, journal 2026-09-26). The same strings are the
          # keys of the omp modelOverrides in the shared ollama provider
          # (features/dev/agentics/harnesses/_omp-ollama-provider.nix).
          loadModels = [
            "qwen3.8:27b" # Slayer of Opus 4.6!
            "qwen3.8:27b-mtp-q4_K_M"
            "jetelain/Qwen3.8-27B:latest" # Unsloth Dynamic V3.0 GGUFs, UD-Q4_K_XL, 128k
            "mannix/omnimerge-v6:vision-Q4_K_M" # Weight tuned from qwen3.8:27b, vision
            "orcarouter/Qwen3.8-27B-Uncensored:q4_K_M" # Abliterated
            "smtek/Swift-Qwen3.8-27B:dflash2" # Block-diffusion draft model
            "smtek/Swift-Qwen3.8-27B:map-k4v" # Engram
            "hf.co/bartowski/Altworld_Hemmingway-1-GGUF:q4_K_M" # 27B Qwen3.8 finetune, everyday writing (EQ-Bench 4 ~1330)
            "Distendo/zen-pro" # Unknown pull
            "SparkLLM/Spark-X2.5-4B" # reasoning, coding
            "openbmb/minicpm5-2b:f16" # reasoning, coding
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
            # swap-era setting; an evergreen resident starves the gaming
            # session on the shared 3090 (VRAM prompt-cache evictions +
            # host page-allocation failures, journal 2026-09-26).
            OLLAMA_KEEP_ALIVE = "5m";

            # Pin to the 3090 ONLY (2026-09-20 fix for "27B models return
            # 404"/no-output): without it ollama's fit-params sees BOTH GPUs
            # and splits layers (34/66 on the 3090 + CPU tail, 1.6 tok/s) —
            # or, worse, parks 2 GiB of 27B KV on the 3060 the desktop runs
            # on (fit log 2026-09-26: "CUDA1 ... -1335 free"). Loads
            # "succeed" but starve whatever else uses the cards.
            # Explicit UUID, not index "0": CUDA enumerates the 3060 first
            # (live check 2026-09-20: index 0 = 3060 a81782bc, index 1 = 3090
            # a4e36250), so "0" would pin the 6 GB 3060 — 27B cannot fit.
            # UUID is also enumerate-order-stable across reboots/dock states.
            # DOCK-ONLY TRADE-OFF: undocked (no 3090) ollama.service fails to
            # start on this pin.
            CUDA_VISIBLE_DEVICES = "GPU-a4e36250-873d-62c5-912e-fde18d238a6c";

            OLLAMA_FLASH_ATTENTION = "1";

            # q4_0 KV (live fit 2026-09-20): at 131072 ctx the hybrid
            # DeltaNet KV is ~2.9 GiB q8_0 and the fit fell 707 MiB short of
            # 66/66 layers (63/66, 1.4 GiB CPU tail). q4_0 halves the KV
            # (~1.45 GiB) -> 66/66 with margin; SSM-cache layers dominate
            # anyway (full_attention_interval=4: only 1/4 of layers carry
            # full-attn KV).
            OLLAMA_KV_CACHE_TYPE = "q4_0";

            # 131072 (2026-09-20): 128k is the floor per user. With q8_0 KV
            # the fit fell 707 MiB short of 66/66 layers at 131072 (see the
            # KV note); q4_0 KV closes the gap with ~700 MiB spare. The omp
            # client's contextWindow pins in _omp-ollama-provider.nix MUST
            # match this value.
            OLLAMA_CONTEXT_LENGTH = "131072";

            OLLAMA_NO_CLOUD = "1";
            OLLAMA_NUM_PARALLEL = "1";
            OLLAMA_MAX_LOADED_MODELS = "1";
          };
        };

        # DELL consumes ollama over the tailnet (see host = "0.0.0.0" above):
        # open 11434 ONLY on tailscale0, never the LAN. networking.firewall
        # merges fine with the sunshine/ssh aspects' port lists.
        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [11434];
      };
    };
  };
}
