{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.provides.to-users = {user, ...}: {
    includes = [
      # `programs.pi-coding-agent` requires overlay which this aspect defines
      den.aspects.dev.agentics.pi
    ];

    homeManager = {
      config,
      lib,
      ...
    }: {
      programs.pi-coding-agent = {
        models = lib.mkMerge [
          {}
          (lib.mkIf (config.services.llama-cpp.enable or false) {
            default = {
              provider = "llama.cpp";
              model = "opus-9b";
            };
            providers = {
              "llama.cpp" = {
                baseUrl = let
                  host = config.services.llama-cpp.settings.host;
                  port = builtins.toString config.services.llama-cpp.settings.port;
                in "http://${host}:${port}/v1";
                api = "openai-completions";
                apiKey = "llama-cpp";
                compat = {
                  supportsDeveloperRole = false;
                  supportsReasoningEffort = false;
                };
                models = [
                  {
                    id = "OmniCoder-9B-Claude-Opus-High-Reasoning-Distill.Q4_K_M";
                    name = "OmniCoder-9B-Claude-Opus-High-Reasoning-Distill.Q4_K_M";
                    reasoning = true;
                  }
                ];
              };
            };
          })
        ];
      };
    };
  };
}
