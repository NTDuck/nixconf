{
  den,
  inputs,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    homeManager = {
      osConfig,
      pkgs,
      ...
    }: {
      home.file.".omp/agent/models.yml".text = ''
        # https://docs.orcarouter.ai/integrations/oh-my-pi
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
        omp = ''
          ORCAROUTER_API_KEY="$(cat ${osConfig.age.secrets."orcarouter-api-key".path} 2>/dev/null)" \
          OPENCODE_API_KEY="$(cat ${osConfig.age.secrets."orcarouter-api-key".path} 2>/dev/null)" \
          OPENROUTER_API_KEY="$(cat ${osConfig.age.secrets."orcarouter-api-key".path} 2>/dev/null)"\
          ${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp}'';
      };
    };
  };
}
