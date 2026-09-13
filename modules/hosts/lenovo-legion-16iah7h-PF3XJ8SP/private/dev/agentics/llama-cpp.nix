{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      config,
      pkgs,
      ...
    }: {
      services.llama-cpp = {
        enable = true;
        package = pkgs.unstable.llama-cpp.override {
          cudaSupport = true;
        };

        host = "127.0.0.1";
        port = 11435;

        # Router mode: sections are model ids, instances spawn on demand
        # with the CLI flags below; GGUFs download into LLAMA_CACHE
        # (/var/cache/llama-cpp) on first use.
        modelsPreset = {
          "openbmb/MiniCPM5-1B-GGUF:Q8_0" = {
            hf-repo = "openbmb/MiniCPM5-1B-GGUF";
            hf-file = "MiniCPM5-1B-Q8_0.gguf";
            load-on-startup = false;
          };

          # eGPU (RTX 3090) class: 16.3 GB, does not fit the 6 GB 3060;
          # declared ready, loads on demand when the eGPU is attached.
          "unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_XL" = {
            hf-repo = "unsloth/Qwen3.8-27B-GGUF";
            hf-file = "Qwen3.8-27B-UD-Q4_K_XL.gguf";
            load-on-startup = true;
          };
        };

        extraFlags = [
          # Device is picked via CUDA_VISIBLE_DEVICES (EnvironmentFile
          # /run/egpu/llama-cpp.env): 3090 UUID when the dock is attached
          # and CUDA-healthy, laptop 3060 otherwise. Pinning by UUID (never
          # CUDA0) keeps the context stable across enumeration order
          # changes — a live CUDA context on a TB-tunneled GPU is what
          # hard-freezes the desktop on cable pull.
          # GPU-only: computation on CUDA, never CPU. --fit off so an
          # over-budget model fails loudly instead of silently falling
          # back to CPU or shrinking layers. (A CUDA-DEAD device would
          # still silently run CPU — guarded upstream by egpu-adopt's
          # CUDA probe, which only flips the env file for a healthy 3090.)
          "--device"
          "CUDA0"
          "-ngl"
          "all"
          "--fit"
          "off"
          # mmap the GGUF: weights tier RAM -> NVMe via page cache with
          # zero CPU layer execution (cold pages fault in on demand).
          "--load-mode"
          "mmap"
          "--flash-attn"
          "on"
          "-c"
          "32768" # native ctx (262k needs yarn; 32k is the sweet spot for KV VRAM)
          # Qwen3.8 official thinking-mode sampling (Qwen model card):
          "--temp"
          "1.0"
          "--top-p"
          "0.95"
          "--top-k"
          "20"
          "--repeat-penalty"
          "1.0"
        ];
      };

      # Device selection is dynamic: egpu-adopt.service rewrites
      # /run/egpu/llama-cpp.env (3090 UUID when the dock is attached AND
      # CUDA-healthy, 3060 UUID otherwise) and restarts this daemon.
      # Pinning by UUID (never CUDA0) keeps the context stable across
      # enumeration order changes.
      # Seed the env file at boot via tmpfiles: egpu-adopt only runs on a
      # dock event, so a dock-less boot previously left /run/egpu/llama-cpp.env
      # missing and the unit crash-looped with Result=resources
      # ("Failed to load environment files", seen 2026-09-13). tmpfiles
      # runs before services start, so the file exists before
      # EnvironmentFile is read; egpu-adopt / egpu-release rewrite it on
      # dock transitions.
      systemd.tmpfiles.rules = [
        "d /run/egpu 0755 root root -"
        # 'f' not 'f+': create-if-missing only, so a pin egpu-adopt wrote
        # mid-session (3090 UUID) survives a later nixos-rebuild switch.
        "f /run/egpu/llama-cpp.env 0644 root root - CUDA_VISIBLE_DEVICES=GPU-a81782bc-e6d4-e015-445a-d413a0e94529"
      ];
      systemd.services.llama-cpp = {
        serviceConfig.EnvironmentFile = "/run/egpu/llama-cpp.env";
      };

      environment.systemPackages = [
        config.services.llama-cpp.package
      ];

      # keep the existing memlock pins from the previous setup
      security.pam.loginLimits = [
        {
          domain = "@users";
          item = "memlock";
          type = "-";
          value = "unlimited";
        }
        {
          domain = "@wheel";
          item = "memlock";
          type = "-";
          value = "unlimited";
        }
      ];

      systemd.settings.Manager.DefaultLimitMEMLOCK = "infinity";
      systemd.user.extraConfig = "DefaultLimitMEMLOCK=infinity";
    };
  };
}
