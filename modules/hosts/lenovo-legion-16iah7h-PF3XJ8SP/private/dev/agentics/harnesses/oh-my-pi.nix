{inputs, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    homeManager = {
      osConfig,
      pkgs,
      ...
    }: {
      home.file.".omp/agent/models.yml".text = ''
        providers:
          # Local llama-cpp router (services.llama-cpp): MiniCPM resident
          # on the laptop 3060; Qwen3.8-27B tiers to the 3090 eGPU when the
          # UT3G dock is attached AND CUDA-healthy (egpu-adopt gates the
          # flip on llama-server --list-devices; a dead-NVRM-bind card
          # stays on the 3060).
          llama-cpp:
            baseUrl: http://${osConfig.services.llama-cpp.host}:${builtins.toString osConfig.services.llama-cpp.port}/v1
            api: openai-completions
            apiKey: none
            models:
              - id: openbmb/MiniCPM5-1B-GGUF:Q8_0
                name: MiniCPM5 1B (local 3060)
                reasoning: false
                input: [text]
                contextWindow: 8192
                maxTokens: 8192

              - id: unsloth/Qwen3.8-27B-GGUF:Q4_K_XL
                name: Qwen3.8 27B (local 3090)
                reasoning: false
                input: [text]
                contextWindow: 32768
                maxTokens: 32768

          # services.ollama (127.0.0.1:11434): qwen3.8 27b on the 3090
          # eGPU, qwen3 30b MoE thinking for reasoning, Qwen3-4B for coding.
          ollama:
            baseUrl: http://127.0.0.1:11434/v1
            api: openai-completions
            apiKey: none
            models:
              - id: qwen3.8:27b
                name: Qwen3.8 27B (ollama 3090)
                reasoning: false
                input: [text]
                contextWindow: 32768
                maxTokens: 32768

              - id: qwen3:30b-a3b-thinking-2507-q4_K_M
                name: Qwen3 30B Thinking (ollama)
                reasoning: true
                input: [text]
                contextWindow: 32768
                maxTokens: 32768

              - id: hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:UD-Q4_K_XL
                name: Qwen3 4B Instruct (ollama)
                reasoning: false
                input: [text]
                contextWindow: 32768
                maxTokens: 32768

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

              - id: zai-org/GLM-5.3-Flash
                name: GLM 5.3 Flash (NetMind)
                contextWindow: 1048576
                maxTokens: 131072
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
