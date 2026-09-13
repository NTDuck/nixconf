{inputs, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    homeManager = {
      osConfig,
      pkgs,
      ...
    }: {
      home.file.".omp/agent/models.yml".text = ''
        providers:
          # services.ollama (127.0.0.1:11434) — main inference engine; qwen3.8-27b-homelab is the RENDERER qwen3.5 clone (ollama #17778 fix), uncensored variant is the JonathanColetti Heretic finetune
          ollama:
            baseUrl: http://127.0.0.1:11434/v1
            api: openai-completions
            auth: none
            models:
              - id: qwen3.8-27b-homelab        # renderer-clone of official qwen3.8:27b (ollama #17778 fix)
                name: Qwen3.8 27B Homelab
                reasoning: true
                input: [text]
                contextWindow: 65536
                maxTokens: 65536
                tokenizer: qwen3
                supportsTools: true
                compat:
                  thinkingFormat: qwen
                  qwenTemplateReasoningEffort: true
              - id: hf.co/JonathanColetti/Qwen3.8-27B-Uncensored-GGUF:Q4_K_M-qwen3.8-27b-homelab   # uncensored Heretic finetune (3090), qwen3.5 renderer clone
                name: Qwen3.8 27B Uncensored
                reasoning: true
                input: [text]
                contextWindow: 65536
                maxTokens: 65536
                tokenizer: qwen3
                supportsTools: true
                compat:
                  thinkingFormat: qwen
                  qwenTemplateReasoningEffort: true
              - id: qwen3:30b-a3b-thinking-2507-q4_K_M   # MoE thinking (clone tag = official id)
                name: Qwen3 30B A3B Thinking
                reasoning: true
                input: [text]
                contextWindow: 32768
                maxTokens: 32768
                tokenizer: qwen3
                supportsTools: true
                compat:
                  thinkingFormat: qwen
                  qwenTemplateReasoningEffort: true
              - id: hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:UD-Q4_K_XL   # 3060-class coding model
                name: Qwen3 4B Instruct (3060)
                reasoning: false
                input: [text]
                contextWindow: 32768
                maxTokens: 32768
                tokenizer: qwen3
                supportsTools: true

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

      home.file.".omp/agent/config.yml".text = ''
        # homelab specialization: local qwen3.8 27b as default+smol (thinking, max effort)
        modelRoles:
          default: ollama/qwen3.8-27b-homelab:max
          smol: ollama/qwen3.8-27b-homelab:low
          slow: ollama/qwen3:30b-a3b-thinking-2507-q4_K_M:high
          plan: ollama/qwen3.8-27b-homelab:xhigh
          advisor: ollama/qwen3:30b-a3b-thinking-2507-q4_K_M:xhigh
        defaultThinkingLevel: max
        cycleOrder:
          - smol
          - default
          - slow
        providers:
          webSearchOrder:
            - duckduckgo
            - perplexity
            - gemini
            - anthropic
            - codex
            - xai
            - zai
            - exa
            - tinyfish
            - jina
            - kagi
            - tavily
            - firecrawl
            - brave
            - kimi
            - parallel
            - synthetic
            - searxng
            - startpage
            - ecosia
            - google
            - mojeek
            - public
        symbolPreset: unicode
        theme:
          dark: titanium
          light: light
        task:
          eager: preferred
        steeringMode: one-at-a-time
        interruptMode: wait
        followUpMode: one-at-a-time
        retry:
          fallbackChains:
            plan:
              - openai-codex/gpt-5.6-luna
            slow:
              - openai-codex/gpt-5.6-luna
        composer:
          shape: box
        dev:
          autoqaConsent: granted
        browser:
          headless: true
          relay: true
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
