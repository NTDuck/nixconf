{inputs, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {...}: {
      age.secrets."orca-key" = {
        file = "${inputs.self}/secrets/orca-key.age";
        owner = "ayin";
        mode = "0400";
      };
    };

    homeManager = {...}: {
      home.file.".omp/agent/models.yml".text = ''
        providers:
          orcarouter:
            baseUrl: https://api.orcarouter.ai/v1
            api: openai-completions
            apiKey: ORCAROUTER_API_KEY
            authHeader: true
            models:
              - id: orcarouter/auto
                name: OrcaRouter Auto
                reasoning: false
                input: [text]
                contextWindow: 200000
                maxTokens: 8192
                compat:
                  supportsDeveloperRole: false
                  maxTokensField: max_tokens
      '';

      home.shellAliases = {
        omp = ''ORCAROUTER_API_KEY="$(cat /run/agenix/orca-key 2>/dev/null)" OPENCODE_API_KEY="$(cat /run/agenix/orca-key 2>/dev/null)" OPENROUTER_API_KEY="$(cat /run/agenix/orca-key 2>/dev/null)" omp'';
      };
    };
  };
}
