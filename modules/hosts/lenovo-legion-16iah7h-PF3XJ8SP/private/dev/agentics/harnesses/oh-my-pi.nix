{
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
        providers:
          # https://docs.orcarouter.ai/integrations/oh-my-pi
          orcarouter:
            baseUrl: https://api.orcarouter.ai/v1
            api: openai-completions
            apiKey: ORCAROUTER_API_KEY
            authHeader: true
            models:
              - id: orcarouter/auto
                name: OrcaRouter
                reasoning: false
                input: [text]
                contextWindow: 200000
                maxTokens: 8192
                compat:
                  supportsDeveloperRole: false
                  maxTokensField: max_tokens

          # https://tabitoken.com/pricing
          tabitoken:
            baseUrl: https://tabitoken.com/v1
            api: openai-completions
            apiKey: TABIAI_API_KEY
            models:
              - id: claude-opus-5
                name: Claude Opus 5
                contextWindow: 200000
                maxTokens: 8192

              - id: claude-opus-5-thinking
                name: Claude Opus 5 (Thinking)
                contextWindow: 200000
                maxTokens: 8192

              - id: claude-opus-4-8
                name: Claude Opus 4.8
                contextWindow: 200000
                maxTokens: 8192

              - id: claude-opus-4-8-thinking
                name: Claude Opus 4.8 (Thinking)
                contextWindow: 200000
                maxTokens: 8192

          # https://netmind.viettel.vn/codev/vi/docs/hub/installation#install-sso
          codev:
            baseUrl: https://netmind.viettel.vn/gateway/v1
            api: openai-completions
            apiKey: CODEV_API_KEY
            authHeader: true
            models:
              - id: MiniMax/MiniMax-M3
                name: MiniMax M3 (NetMind)
                contextWindow: 196608
                maxTokens: 65536

          # FreeToken local edge-native MoE server (http://127.0.0.1:1919)
          freetoken:
            baseUrl: http://127.0.0.1:1919/v1
            api: openai-completions
            apiKey: freetoken
            models:
              - id: Qwen/Qwen3-30B-A3B
                name: Qwen3 30B A3B (FreeToken)
                reasoning: true
                input: [text]
                contextWindow: 131072
                maxTokens: 8192

              - id: Qwen/Qwen3.6-35B-A3B
                name: Qwen3.6 35B A3B (FreeToken)
                reasoning: true
                input: [text]
                contextWindow: 131072
                maxTokens: 8192

              - id: openai/gpt-oss-20b
                name: GPT-OSS 20B (FreeToken)
                reasoning: true
                input: [text]
                contextWindow: 131072
                maxTokens: 8192

              - id: deepseek-ai/DeepSeek-V4-Flash-0731
                name: DeepSeek V4 Flash (FreeToken)
                reasoning: true
                input: [text]
                contextWindow: 131072
                maxTokens: 8192

              - id: google/gemma-4-26B-A4B-it
                name: Gemma 4 26B A4B (FreeToken)
                reasoning: true
                input: [text]
                contextWindow: 131072
                maxTokens: 8192

              - id: nvidia/GLM-5.2-NVFP4
                name: GLM 5.2 NVFP4 (FreeToken)
                reasoning: true
                input: [text]
                contextWindow: 131072
                maxTokens: 8192

              - id: nvidia/MiniMax-M2.5-NVFP4
                name: MiniMax M2.5 NVFP4 (FreeToken)
                reasoning: true
                input: [text]
                contextWindow: 131072
                maxTokens: 8192
      '';

      home.shellAliases = {
        omp = ''
          CODEV_API_KEY="$(cat ${osConfig.age.secrets."codev-api-key".path})" \
          ORCAROUTER_API_KEY="$(cat ${osConfig.age.secrets."orcarouter-api-key".path})" \
          OPENCODE_API_KEY="$(cat ${osConfig.age.secrets."opencode-api-key".path})" \
          OPENROUTER_API_KEY="$(cat ${osConfig.age.secrets."openrouter-api-key".path})" \
          TABIAI_API_KEY="$(cat ${osConfig.age.secrets."tabiai-api-key".path})" \
          REASONIX_SCAVENGE=1 \
          REASONIX_RESULT_CAP_TOKENS=3000 \
          ${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp}/bin/omp'';
      };
    };
  };
}
