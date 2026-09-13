{...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {pkgs, ...}: {
      # Reinstalled 2026-09-13 (removed in 013592c in favor of llama-cpp,
      # restored alongside it: llama-cpp router keeps 11435, ollama owns 11434).
      services.ollama = {
        enable = true;
        package = pkgs.unstable.ollama-cuda;

        host = "127.0.0.1";
        port = 11434;

        loadModels = [
          # eGPU (RTX 3090): flagship local general model
          "qwen3.8:27b"
          # reasoning: MoE thinking model
          "qwen3:30b-a3b-thinking-2507-q4_K_M"
          # coding: small instruct model, fits the laptop 3060
          "hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:UD-Q4_K_XL"
        ];

        syncModels = true;

        environmentVariables = {
          OLLAMA_FLASH_ATTENTION = "1";
          OLLAMA_KV_CACHE_TYPE = "q4_0";
          OLLAMA_KEEP_ALIVE = "5m";
          # 32k context: sweet spot for KV VRAM (same rationale as
          # llama-cpp.nix); ollama defaults to 4k otherwise.
          OLLAMA_CONTEXT_LENGTH = "32768";
        };
      };
    };
  };
}
