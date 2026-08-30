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
        port = 8080;

        modelsPreset = {
          "*" = {
            n-gpu-layers = "99";
            flash-attn = "1";
            cache-type-k = "q4_0";
            cache-type-v = "q4_0";
            jinja = "1";
          };

          # Overall, general
          "mistral:7b-instruct-v0.2-q5_0" = {
            hf-repo = "TheBloke/Mistral-7B-Instruct-v0.2-GGUF";
            hf-file = "mistral-7b-instruct-v0.2.Q5_0.gguf";
            alias = "mistral:7b-instruct-v0.2-q5_0";
          };

          # Coding
          "qwen2.5-coder:7b-base-q5_0" = {
            hf-repo = "Qwen/Qwen2.5-Coder-7B-GGUF";
            hf-file = "qwen2.5-coder-7b-q5_0.gguf";
            alias = "qwen2.5-coder:7b-base-q5_0";
          };

          # Reasoning
          "qwen2.5:7b-instruct-q5_0" = {
            hf-repo = "Qwen/Qwen2.5-7B-Instruct-GGUF";
            hf-file = "qwen2.5-7b-instruct-q5_0.gguf";
            alias = "qwen2.5:7b-instruct-q5_0";
          };

          # Multimodal
          "llava:7b-v1.6-mistral-q5_0" = {
            hf-repo = "cjpais/llava-1.6-mistral-7b-gguf";
            hf-file = "llava-v1.6-mistral-7b.Q5_0.gguf";
            alias = "llava:7b-v1.6-mistral-q5_0";
          };

          # Creative, chat
          "deepseek-r1:7b" = {
            hf-repo = "unsloth/DeepSeek-R1-Distill-Qwen-7B-GGUF";
            hf-file = "DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf";
            alias = "deepseek-r1:7b";
          };

          # Reading
          "yi:6b-200k-q3_K_S" = {
            hf-repo = "TheBloke/Yi-6B-200K-GGUF";
            hf-file = "yi-6b-200k.Q3_K_S.gguf";
            alias = "yi:6b-200k-q3_K_S";
          };

          # Dense, coding
          "qwen3.5:4b-q4_K_M" = {
            hf-repo = "unsloth/Qwen3.5-4B-GGUF";
            hf-file = "Qwen3.5-4B-Q4_K_M.gguf";
            alias = "qwen3.5:4b-q4_K_M";
          };

          "hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:UD-Q4_K_XL" = {
            hf-repo = "unsloth/Qwen3-4B-Instruct-2507-GGUF";
            hf-file = "Qwen3-4B-Instruct-2507-UD-Q4_K_XL.gguf";
            alias = "hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:UD-Q4_K_XL";
          };

          "hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:Q5_K_M" = {
            hf-repo = "unsloth/Qwen3-4B-Instruct-2507-GGUF";
            hf-file = "Qwen3-4B-Instruct-2507-Q5_K_M.gguf";
            alias = "hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:Q5_K_M";
          };

          # MoE, reasoning
          "lfm2.5:8b-a1b-q4_K_M" = {
            hf-repo = "LiquidAI/lfm2.5-8b-a1b-GGUF";
            hf-file = "LFM2.5-8B-A1B-Q4_K_M.gguf";
            alias = "lfm2.5:8b-a1b-q4_K_M";
          };
          # eGPU
          "qwen3.8:27b" = {
            hf-repo = "unsloth/Qwen3.8-27B-GGUF";
            hf-file = "Qwen3.8-27B-Q4_K_M.gguf";
            alias = "qwen3.8:27b";
          };
        };
      };

      environment.systemPackages = [
        config.services.llama-cpp.package
        (pkgs.writeShellScriptBin "llama-cpp" ''
          exec ${config.services.llama-cpp.package}/bin/llama-cli "$@"
        '')
      ];
    };
  };
}
