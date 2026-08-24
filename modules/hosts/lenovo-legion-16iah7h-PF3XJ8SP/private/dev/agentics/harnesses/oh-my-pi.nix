{inputs, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {...}: {
      age.secrets."orca-key" = {
        file = "${inputs.self}/secrets/orca-key.age";
        owner = "ayin";
        mode = "0400";
      };

      environment.extraInit = ''
        if [ -r /run/agenix/orca-key ]; then
          export ORCA_KEY="$(cat /run/agenix/orca-key)"
        fi
      '';
    };

    homeManager = {...}: {
      home.file.".omp/agent/models.yml".text = ''
        providers:
          orcarouter:
            baseUrl: https://api.orcarouter.ai/v1
            api: openai-completions
            apiKey: ORCA_KEY
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

      programs.zsh.initContent = ''
        if [ -r /run/agenix/orca-key ]; then
          export ORCA_KEY="$(cat /run/agenix/orca-key)"
        fi
      '';
    };
  };
}
