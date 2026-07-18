{
  den,
  lib,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.provides.to-users.homeManager = {osConfig, ...}:
    lib.mkIf osConfig.services.ollama.enable {
      programs.opencode.settings = {
        model = lib.mkForce "ollama/${builtins.elemAt osConfig.services.ollama.loadModels 0}";
        small_model = lib.mkForce "ollama/${builtins.elemAt osConfig.services.ollama.loadModels 1}";

        provider.ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama";
          options.apiKey = "none";
          options.baseURL = "http://${osConfig.services.ollama.host}:${toString osConfig.services.ollama.port}/v1";
          options.timeout = 600000;
          options.chunkTimeout = 60000;

          models = builtins.listToAttrs (map (model: {
              name = model;
              value.name = model;
            })
            osConfig.services.ollama.loadModels);
        };
      };
    };
}
