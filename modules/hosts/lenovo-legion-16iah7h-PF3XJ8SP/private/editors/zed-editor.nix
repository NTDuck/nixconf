{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    homeManager = {
      programs.zed-editor.userSettings = {
        agent = {
          default_model = {
            # ollama's OpenAI-compat endpoint (bonsai :8080 removed
            # 2026-09-21). ollama serves /v1/chat/completions; the ollama
            # provider entry already pins real context windows in
            # dev/agentics/harnesses/oh-my-pi.nix.
            provider = "openai";
            model = "qwen3.8:27b-mtp-q4_K_M";
            api_url = "http://127.0.0.1:11434/v1";
          };
          dock = "right";
          favourite_models = [];
          model_parameters = [];
        };
      };
    };
  };
}
