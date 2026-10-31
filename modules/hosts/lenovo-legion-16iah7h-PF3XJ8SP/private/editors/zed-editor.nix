{...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    homeManager = {
      programs.zed-editor.userSettings = {
        agent = {
          default_model = {
            # ashalliants ninfer-0.15.0 DFlash2 (OpenAI-compat endpoint,
            # ../dev/agentics/ninfer.nix). ashalliants serves
            # /v1/chat/completions; the ashalliants provider entry in
            # dev/agentics/harnesses/oh-my-pi.nix pins the real context
            # window (262144, NINFER_FALLBACK=off keeps it exact).
            provider = "openai";
            model = "qwen3.8-27b";
            api_url = "http://127.0.0.1:8092/v1";
          };
          dock = "right";
          favourite_models = [];
          model_parameters = [];
        };
      };
    };
  };
}
