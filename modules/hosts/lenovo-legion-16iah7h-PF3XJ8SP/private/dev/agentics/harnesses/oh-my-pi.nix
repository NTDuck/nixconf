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

          # llama-cpp server (local)
          llama-cpp:
            baseUrl: http://127.0.0.1:8080/v1
            api: openai-completions
            apiKey: none
            models:
              - id: mistral:7b-instruct-v0.2-q5_0
                name: Mistral 7B Instruct v0.2 Q5_0 (llama-cpp)
                reasoning: false
                input: [text]
                contextWindow: 32768
                maxTokens: 8192

              - id: qwen2.5-coder:7b-base-q5_0
                name: Qwen 2.5 Coder 7B Base Q5_0 (llama-cpp)
                reasoning: false
                input: [text]
                contextWindow: 32768
                maxTokens: 8192

              - id: qwen2.5:7b-instruct-q5_0
                name: Qwen 2.5 7B Instruct Q5_0 (llama-cpp)
                reasoning: false
                input: [text]
                contextWindow: 32768
                maxTokens: 8192

              - id: llava:7b-v1.6-mistral-q5_0
                name: LLaVA 7B v1.6 Mistral Q5_0 (llama-cpp)
                reasoning: false
                input: [text, image]
                contextWindow: 32768
                maxTokens: 8192

              - id: deepseek-r1:7b
                name: DeepSeek R1 7B (llama-cpp)
                reasoning: true
                input: [text]
                contextWindow: 131072
                maxTokens: 32768

              - id: yi:6b-200k-q3_K_S
                name: Yi 6B 200K Q3_K_S (llama-cpp)
                reasoning: false
                input: [text]
                contextWindow: 200000
                maxTokens: 8192

              - id: qwen3.5:4b-q4_K_M
                name: Qwen 3.5 4B Q4_K_M (llama-cpp)
                reasoning: true
                input: [text, image]
                contextWindow: 262144
                maxTokens: 32768

              - id: hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:UD-Q4_K_XL
                name: Qwen3 4B Instruct 2507 UD-Q4_K_XL (llama-cpp)
                reasoning: true
                input: [text]
                contextWindow: 262144
                maxTokens: 32768

              - id: hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:Q5_K_M
                name: Qwen3 4B Instruct 2507 Q5_K_M (llama-cpp)
                reasoning: true
                input: [text]
                contextWindow: 262144
                maxTokens: 32768

              - id: lfm2.5:8b-a1b-q4_K_M
                name: LFM 2.5 8B A1B Q4_K_M (llama-cpp)
                reasoning: true
                input: [text]
                contextWindow: 128000
                maxTokens: 32768

              - id: gpt-oss:20b
                name: GPT-OSS 20B (llama-cpp)
                reasoning: true
                input: [text]
                contextWindow: 131072
                maxTokens: 32768

              - id: qwen3:30b-a3b-thinking-2507-q4_K_M
                name: Qwen3 30B A3B Thinking 2507 Q4_K_M (llama-cpp)
                reasoning: true
                input: [text]
                contextWindow: 262144
                maxTokens: 32768

              - id: qwen3.8:27b
                name: Qwen 3.8 27B (llama-cpp)
                reasoning: true
                input: [text, image]
                contextWindow: 262144
                maxTokens: 32768
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
