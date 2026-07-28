{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {pkgs, ...}: {
      services.ollama = {
        enable = true;
        package = pkgs.unstable.ollama-cuda;

        host = "127.0.0.1";
        port = 11434;

        loadModels = [
          # `npx llm-checker recommend`
          "mistral:7b-instruct-v0.2-q5_0" # overall, general
          "qwen2.5-coder:7b-base-q5_0" # coding
          "qwen2.5:7b-instruct-q5_0" # reasoning
          "llava:7b-v1.6-mistral-q5_0" # multimodal
          "deepseek-r1:7b" # creative, chat
          "yi:6b-200k-q3_K_S" # reading

          # Base
          "qwen3.5:4b-q4_K_M"

          # Fine-tuned, quantitized
          "hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:UD-Q4_K_XL"
          "hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:Q5_K_M"
        ];

        environmentVariables = {
          OLLAMA_FLASH_ATTENTION = "1";
          OLLAMA_KV_CACHE_TYPE = "q4_0";
        };
      };
    };
  };
}
