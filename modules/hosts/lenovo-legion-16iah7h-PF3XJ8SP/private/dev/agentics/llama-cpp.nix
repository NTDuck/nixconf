{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.provides.to-users = {user, ...}: {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      services.llama-cpp = {
        # package = lib.mkForce (pkgs.unstable.llama-cpp.override {
        #   cudaSupport = true;
        # });

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
