{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.nixos = {pkgs, ...}: {
    services.ollama = {
      enable = true;
      package = pkgs.unstable.ollama-cuda;
      host = "127.0.0.1";
      port = 11434;
      loadModels = [
        "gpt-oss:20b"
        "qwen2.5-coder:1.5b"
        "qwen3:30b-a3b"
        "qwen3-coder:30b"
        "qwen3:8b"
        "phi4-reasoning:14b"
        "deepseek-coder-v2:16b"
        "magistral:24b"
        "gemma3:12b"
        "granite3.3:8b"
        "glm-4.7-flash"
        "qwen2.5-coder:3b"
      ];

      environmentVariables = {
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_KV_CACHE_TYPE = "q4_0";
      };
    };
  };
}
