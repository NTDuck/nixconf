{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.dev.agentics.llama-cpp = {
    nixos = {pkgs, ...}: {
      services.llama-cpp = {
        package = pkgs.unstable.llama-cpp.override {
          cudaSupport = true;
        };

        modelsPreset = {
          "OmniCoder-9B-Claude-Opus-High-Reasoning-Distill.Q4_K_M" = {
            hf-repo = "mradermacher/OmniCoder-9B-Claude-Opus-High-Reasoning-Distill-GGUF";
            hf-file = "OmniCoder-9B-Claude-Opus-High-Reasoning-Distill.Q4_K_M.gguf";
            n-gpu-layers = 28;
            temperature = 0.7;
            top-p = 0.95;
          };
        };
      };
    };
  };
}
