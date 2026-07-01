{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.provides.to-users = {user, ...}: {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      services.llama-cpp = {
        package = lib.mkForce (pkgs.unstable.llama-cpp.override {
          cudaSupport = true;
        });

        modelsPreset = {
          "OmniCoder-9B-Claude-Opus-High-Reasoning-Distill.Q4_K_M" = {
            hf-repo = "mradermacher/OmniCoder-9B-Claude-Opus-High-Reasoning-Distill-GGUF";
            hf-file = "OmniCoder-9B-Claude-Opus-High-Reasoning-Distill.Q4_K_M.gguf";
            n-gpu-layers = 28;
            temperature = 0.7;
            top-p = 0.95;
          };
          "Mirage-OpenReasoning-Nemotron-7B.Q4_K_M" = {
            hf-repo = "mradermacher/Mirage-OpenReasoning-Nemotron-7B-GGUF";
            hf-file = "Mirage-OpenReasoning-Nemotron-7B.Q4_K_M.gguf";
            n-gpu-layers = 35;
            temperature = 0.7;
            top-p = 0.95;
          };
          "Qwen3-4B-Function-Calling-Pro" = {
            hf-repo = "Manojb/Qwen3-4B-toolcalling-gguf-codex";
            hf-file = "Qwen3-4B-Function-Calling-Pro.gguf";
            n-gpu-layers = 35;
            temperature = 0.7;
            top-p = 0.95;
          };
          "IBM-Agentic-Nvidia-Q4_K_M" = {
            hf-repo = "WithinUsAI/Nvidia.Agentic.Coder-4B-GGUF";
            hf-file = "IBM-Agentic-Nvidia-Q4_K_M.gguf";
            n-gpu-layers = 35;
            temperature = 0.7;
            top-p = 0.95;
          };
          "qwen3-4b-function-calling-xlam-unsloth.q4_k_m" = {
            hf-repo = "ermiaazarkhalili/Qwen3-4B-Function-Calling-xLAM-Unsloth-GGUF";
            hf-file = "qwen3-4b-function-calling-xlam-unsloth.q4_k_m.gguf";
            n-gpu-layers = 35;
            temperature = 0.7;
            top-p = 0.95;
          };
        };
      };
    };
  };
}
