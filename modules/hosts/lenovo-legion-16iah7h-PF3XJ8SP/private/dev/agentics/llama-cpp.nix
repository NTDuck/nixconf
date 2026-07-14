{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.nixos = {
    pkgs,
    lib,
    ...
  }: {
    services.llama-cpp = {
      package = lib.mkForce (pkgs.unstable.llama-cpp.override {
        cudaSupport = true;
      });

      modelsPreset = {
        gemma-3-it-1b = {
          alias = "Gemma 3 IT [1B]";
          hf-repo = "google/gemma-3-1b-it-qat-q4_0-gguf";
          hf-file = "gemma-3-1b-it-q4_0.gguf";
          ctx-size = 32768;
          n-gpu-layers = 999;
          temp = "0.7";
          top-p = "0.95";
        };
        gemma-3-it-4b = {
          alias = "Gemma 3 IT [4B]";
          hf-repo = "google/gemma-3-4b-it-qat-q4_0-gguf";
          hf-file = "gemma-3-4b-it-q4_0.gguf";
          ctx-size = 32768;
          n-gpu-layers = 999;
          temp = "0.7";
          top-p = "0.95";
        };
        gemma-3-it-12b = {
          alias = "Gemma 3 IT [12B]";
          hf-repo = "google/gemma-3-12b-it-qat-q4_0-gguf";
          hf-file = "gemma-3-12b-it-q4_0.gguf";
          ctx-size = 32768;
          n-gpu-layers = 0;
          temp = "0.7";
          top-p = "0.95";
        };
        gemma-3-it-27b = {
          alias = "Gemma 3 IT [27B]";
          hf-repo = "google/gemma-3-27b-it-qat-q4_0-gguf";
          hf-file = "gemma-3-27b-it-q4_0.gguf";
          ctx-size = 32768;
          n-gpu-layers = 0;
          temp = "0.7";
          top-p = "0.95";
        };
        qwen3-thinking-30b-a3b = {
          alias = "Qwen3 Thinking [30B]";
          hf-repo = "unsloth/Qwen3-30B-A3B-Thinking-2507-GGUF";
          hf-file = "Qwen3-30B-A3B-Thinking-2507-Q4_K_M.gguf";
          ctx-size = 32768;
          n-gpu-layers = 0;
          temp = "0.6";
          top-p = "0.95";
        };
        qwen2_5-coder-3b = {
          alias = "Qwen2.5 Coder [3B]";
          hf-repo = "Qwen/Qwen2.5-Coder-3B-Instruct-GGUF";
          hf-file = "qwen2.5-coder-3b-instruct-q4_k_m.gguf";
          ctx-size = 32768;
          n-gpu-layers = 999;
          flash-attn = "on";
          temp = "0.2";
          top-p = "0.9";
        };
      };
    };

    systemd.services.llama-cpp.serviceConfig.EnvironmentFile = "-/etc/llama-cpp/huggingface.env";
  };
}
