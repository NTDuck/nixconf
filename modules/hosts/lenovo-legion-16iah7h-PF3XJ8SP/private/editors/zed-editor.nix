{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    homeManager = {osConfig, ...}: {
      programs.zed-editor.userSettings = {
        agent = {
          default_model = {
            provider = "openai";
            model = "openbmb/MiniCPM5-1B-GGUF:Q8_0";
            api_url = "http://${osConfig.services.llama-cpp.host}:${builtins.toString osConfig.services.llama-cpp.port}/v1";
            enable_thinking = true;
          };
          dock = "right";
          favourite_models = [];
          model_parameters = [];
        };
      };
    };
  };
}
